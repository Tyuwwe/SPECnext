import { hilog } from '@kit.PerformanceAnalysisKit';
import testNapi, { queryCpuCount } from 'libentry.so';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import window from '@ohos.window';
import { zlib, BusinessError } from '@kit.BasicServicesKit';

async function resourceFile(resourcePath: string) {
  let uint8Array: Uint8Array = getContext()
    .resourceManager
    .getRawFileContentSync(resourcePath);
  let fileName = resourcePath.substring(resourcePath.lastIndexOf('/') + 1);
  // console.log("${tag} fileName:${fileName}");

  let filePath = getContext().filesDir + '/' + fileName;
  if (fs.accessSync(filePath)) {
    fs.unlinkSync(filePath)
  }
  let file: fs.File = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
  fs.writeSync(file.fd, uint8Array.buffer);
  fs.closeSync(file);
  // console.log("${tag} filePath:${filePath}");
  return filePath;
}

async function decompressBundle(bundleRelPath: string) {
  let uint8Array: Uint8Array = getContext()
    .resourceManager
    .getRawFileContentSync(bundleRelPath)
  const fileName = bundleRelPath.substring(bundleRelPath.lastIndexOf('/') + 1)

  const cwd = getContext().filesDir
  const bundlePath = cwd + '/' + fileName
  await zlib.decompressFile(bundlePath, cwd)
}

async function runTestList(testList: Array<number>, cpu: number, func: object) {
  return new Promise<number>((resolve, reject) => {
    let ret = testNapi.runTests(testList, cpu, func);
    if (ret == 0) resolve(0);
    else reject(ret);
  })
}

async function runTest(testNo: number, func: object) {
  return new Promise<number>((resolve, reject) => {
    let ret = testNapi.runTest(testNo, func);
    if (ret == 0) resolve(0);
    else reject(ret);
  })
}

enum TestType {
  INTrate,
  FPrate,
  INTspeed,
  FPspeed,
  Other
}

function testTypeToString(type: TestType) {
  switch (type) {
    case TestType.INTrate:
      return "INTrate"
    case TestType.FPrate:
      return "FPrate"
    case TestType.INTspeed:
      return "INTspeed"
    case TestType.FPspeed:
      return "FPspeed"
    case TestType.Other:
    default:
      return "Other"
  }
}

enum Status {
  Skipped = 0,
  Pending,
  Initializing,
  Running,
  Message,
  Failed,
  Completed,
  Error,
  Idle,
}

function statusToString(status: Status) {
  switch (status) {
    case Status.Skipped:
      return "Skipped";
    case Status.Pending:
      return "Pending";
    case Status.Initializing:
      return "Initializing";
    case Status.Running:
      return "Running";
    case Status.Pending:
      return "Pending";
    case Status.Failed:
      return "Failed";
    case Status.Completed:
      return "Completed";
      case Status.Failed:
      return "Failed";
    case Status.Error:
      return "Error";
  }
  return "";
}

@Observed
class TestItem {
  public id: number
  public name: string;
  public type: TestType;
  public checked: boolean;
  public status: Status;
  public reftime: number;
  public time: number;
  public score: number;
  public errmsg: string;

  constructor(name: string, type: TestType, checked: boolean, status: Status, reftime: number, time: number, score: number, errmsg: string) {
    this.id = parseInt(name.split('.')[0])
    this.name = name;
    this.type = type;
    this.checked = checked;
    this.status = status;
    this.reftime = reftime;
    this.time = time;
    this.score = score;
    this.errmsg = errmsg
  }
}

@Entry
@Component
struct Index {
  @State message: string = 'Idle';
  @State sz: number = 30;
  cpuCount: number = 0;
  @State cpuOptions: Array<SelectOption> = [];
  @State currentCpuSelection: number = -1;
  path: string = "";
  @State refreshCount: number = 0;
  @State globalStatus: Status = Status.Idle;

  private context: common.BaseContext = getContext(this) as common.BaseContext

  @State testList: Array<TestItem> = [
    // INTrate
    new TestItem('500.perlbench_r', TestType.INTrate, false, Status.Skipped, 1592, -1, -1, ""),
    new TestItem('502.gcc_r',       TestType.INTrate, false, Status.Skipped, 1416, -1, -1, ""),
    new TestItem('505.mcf_r',       TestType.INTrate, false, Status.Skipped, 1616, -1, -1, ""),
    new TestItem('520.omnetpp_r',   TestType.INTrate, false, Status.Skipped, 1312, -1, -1, ""),
    new TestItem('523.xalancbmk_r', TestType.INTrate, false, Status.Skipped, 1056, -1, -1, ""),
    new TestItem('525.x264_r',      TestType.INTrate, false, Status.Skipped, 1751, -1, -1, ""),
    new TestItem('531.deepsjeng_r', TestType.INTrate, false, Status.Skipped, 1146, -1, -1, ""),
    new TestItem('541.leela_r',     TestType.INTrate, false, Status.Skipped, 1656, -1, -1, ""),
    new TestItem('548.exchange2_r', TestType.INTrate, false, Status.Skipped, 2620, -1, -1, ""),
    new TestItem('557.xz_r',        TestType.INTrate, false, Status.Skipped, 1080, -1, -1, ""),

    // FPrate
    new TestItem('503.bwaves_r',    TestType.FPrate, false, Status.Skipped, 10028, -1, -1, ""),
    new TestItem('507.cactuBSSN_r', TestType.FPrate, false, Status.Skipped, 16670, -1, -1, ""),
    new TestItem('508.namd_r',      TestType.FPrate, false, Status.Skipped, 950,   -1, -1, ""),
    new TestItem('510.parest_r',    TestType.FPrate, false, Status.Skipped, 2616,  -1, -1, ""),
    new TestItem('511.povray_r',    TestType.FPrate, false, Status.Skipped, 2335,  -1, -1, ""),
    new TestItem('519.lbm_r',       TestType.FPrate, false, Status.Skipped, 1054,  -1, -1, ""),
    new TestItem('521.wrf_r',       TestType.FPrate, false, Status.Skipped, 2240,  -1, -1, ""),
    new TestItem('526.blender_r',   TestType.FPrate, false, Status.Skipped, 1523,  -1, -1, ""),
    new TestItem('527.cam4_r',      TestType.FPrate, false, Status.Skipped, 8863,  -1, -1, ""),
    new TestItem('538.imagick_r',   TestType.FPrate, false, Status.Skipped, 2487,  -1, -1, ""),
    new TestItem('544.nab_r',       TestType.FPrate, false, Status.Skipped, 1683,  -1, -1, ""),
    new TestItem('549.fotonik3d_r', TestType.FPrate, false, Status.Skipped, 3897,  -1, -1, ""),
    new TestItem('554.roms_r',      TestType.FPrate, false, Status.Skipped, 1103,  -1, -1, ""),

    // INTspeed
    new TestItem('600.perlbench_s', TestType.INTspeed, false, Status.Skipped, 1774,  -1, -1, ""),
    new TestItem('602.gcc_s',       TestType.INTspeed, false, Status.Skipped, 3981,  -1, -1, ""),
    new TestItem('605.mcf_s',       TestType.INTspeed, false, Status.Skipped, 4721,  -1, -1, ""),
    new TestItem('620.omnetpp_s',   TestType.INTspeed, false, Status.Skipped, 1630,  -1, -1, ""),
    new TestItem('623.xalancbmk_s', TestType.INTspeed, false, Status.Skipped, 1417,  -1, -1, ""),
    new TestItem('625.x264_s',      TestType.INTspeed, false, Status.Skipped, 1764,  -1, -1, ""),
    new TestItem('631.deepsjeng_s', TestType.INTspeed, false, Status.Skipped, 1432,  -1, -1, ""),
    new TestItem('641.leela_s',     TestType.INTspeed, false, Status.Skipped, 1706,  -1, -1, ""),
    new TestItem('657.xz_s',        TestType.INTspeed, false, Status.Skipped, 6182,  -1, -1, ""),

    // FPspeed
    new TestItem('619.lbm_s',       TestType.FPspeed, false, Status.Skipped, 5238,  -1, -1, ""),
    new TestItem('638.imagick_s',   TestType.FPspeed, false, Status.Skipped, 14425,  -1, -1, ""),
    new TestItem('644.nab_s',       TestType.FPspeed, false, Status.Skipped, 17472,  -1, -1, ""),

    // Other
    new TestItem('9994.stream',      TestType.Other, false, Status.Skipped, 1,  -1, -1, ""),
    new TestItem('9995.ffmpeg',      TestType.Other, false, Status.Skipped, 1,  -1, -1, ""),
    new TestItem('9996.p7zip',       TestType.Other, false, Status.Skipped, 1,  -1, -1, ""),
    new TestItem('9997.llama-bench',TestType.Other, false, Status.Skipped, 1,  -1, -1, ""),
    new TestItem('9998.c2clat',      TestType.Other, false, Status.Skipped, 1,  -1, -1, ""),
    new TestItem('9999.vkpeak',      TestType.Other, false, Status.Skipped, 1,  -1, -1, ""),
  ];


  onStateChange = async (newStatus: Status, test: number, time: number, msg: string, timestamp: number) => {
    const TEST_GLOBAL = -1
    // this.message = message

    if (test == TEST_GLOBAL) {
      if (newStatus != Status.Message)
        this.globalStatus = newStatus
      switch (newStatus) {
        case Status.Initializing:
          this.message += `\n[${timestamp}] `
          this.message += "Initializing..."
          return
        case Status.Message:
          this.message += `\n[${timestamp}] `
          this.message += msg
          return
        case Status.Error:
          this.message += `\n[${timestamp}] `
          this.message += "Failed with error: " + msg
          return
        case Status.Completed:
          this.message += `\n[${timestamp}] `
          this.message += "All tests completed."
          return
      }
      // if (newStatus == Status.Completed) {
      //   this.message = "All tests completed."
      //   return
      // }
    }

    let idx = this.testList.findIndex(e => e.id == test);
    this.testList[idx].status = newStatus
    this.testList[idx].errmsg = msg

    switch (newStatus) {
      case Status.Initializing:
        this.message += `\n[${timestamp}] `
        this.message += "Setting up " + this.testList[idx].name + "..."
        break
      case Status.Running:
        this.message += `\n[${timestamp}] `
        this.message += "Running " + this.testList[idx].name + "..."
        break
      case Status.Completed:
          this.message += `\n[${timestamp}] `
          this.message += this.testList[idx].name + " completed, elapsed " + time.toFixed(2) + "s."
          this.testList[idx].time = time
          this.testList[idx].score = this.testList[idx].reftime / time
        break
      case Status.Error:
        this.message += `\n[${timestamp}] `
        this.message += this.testList[idx].name + " failed with: " + msg
        break
      case Status.Idle:
        this.message += `\n[${timestamp}] `
        this.message += "Idle"
        break
      default:
        this.message += `\n[${timestamp}] `
        this.message += "Unknown"
        break
    }
    // this.message = "state: " + status + ", " + test.toString() + ", msg: " + message
  }

  build() {
    Row() {
      Column() {
        // Header Checkbox
        Row() {
          Column() {
            CheckboxGroup({ group: testTypeToString(TestType.INTrate) })
              .enabled(this.globalStatus == Status.Idle)
            Text(testTypeToString(TestType.INTrate))
          }.padding({ left: '2%', right: '2%' })
          Column() {
            CheckboxGroup({ group: testTypeToString(TestType.FPrate) })
              .enabled(this.globalStatus == Status.Idle)
            Text(testTypeToString(TestType.FPrate))
          }.padding({ left: '2%', right: '2%' })
          Column() {
            CheckboxGroup({ group: testTypeToString(TestType.INTspeed) })
              .enabled(this.globalStatus == Status.Idle)
            Text(testTypeToString(TestType.INTspeed))
          }.padding({ left: '2%', right: '2%' })
          Column() {
            CheckboxGroup({ group: testTypeToString(TestType.FPspeed) })
              .enabled(this.globalStatus == Status.Idle)
            Text(testTypeToString(TestType.FPspeed))
          }.padding({ left: '2%', right: '2%' })
          Column() {
            CheckboxGroup({ group: testTypeToString(TestType.Other) })
              .enabled(this.globalStatus == Status.Idle)
            Text(testTypeToString(TestType.Other))
          }.padding({ left: '2%', right: '2%' })
        }
        // Test scroll view
        Scroll() {
          Column() {
            // INTrate tests
            Text(testTypeToString(TestType.INTrate))
              .fontSize(15)
              .fontColor(0xCCCCCC)
              .width('100%')
              .padding('2%')
              .textAlign(TextAlign.Start)
            Divider().strokeWidth(3).color('#F1F3F5')
            ForEach(this.testList, (item: TestItem) => {
              if (item.type == TestType.INTrate)
                TestRow({ globalStatus: this.globalStatus, test: item })
            })

            // FPrate tests
            Text(testTypeToString(TestType.FPrate))
              .fontSize(15)
              .fontColor(0xCCCCCC)
              .width('100%')
              .padding('2%')
              .textAlign(TextAlign.Start)
            Divider().strokeWidth(3).color('#F1F3F5')
            ForEach(this.testList, (item: TestItem) => {
              if (item.type == TestType.FPrate)
                TestRow({ globalStatus: this.globalStatus, test: item })
            })

            // INTspeed tests
            Text(testTypeToString(TestType.INTspeed))
              .fontSize(15)
              .fontColor(0xCCCCCC)
              .width('100%')
              .padding('2%')
              .textAlign(TextAlign.Start)
            Divider().strokeWidth(3).color('#F1F3F5')
            ForEach(this.testList, (item: TestItem) => {
              if (item.type == TestType.INTspeed)
                TestRow({ globalStatus: this.globalStatus, test: item })
            })

            // FPspeed tests
            Text(testTypeToString(TestType.FPspeed))
              .fontSize(15)
              .fontColor(0xCCCCCC)
              .width('100%')
              .padding('2%')
              .textAlign(TextAlign.Start)
            Divider().strokeWidth(3).color('#F1F3F5')
            ForEach(this.testList, (item: TestItem) => {
              if (item.type == TestType.FPspeed)
                TestRow({ globalStatus: this.globalStatus, test: item })
            })

            // Other tests
            Text(testTypeToString(TestType.Other))
              .fontSize(15)
              .fontColor(0xCCCCCC)
              .width('100%')
              .padding('2%')
              .textAlign(TextAlign.Start)
            Divider().strokeWidth(3).color('#F1F3F5')
            ForEach(this.testList, (item: TestItem) => {
              if (item.type == TestType.Other)
                TestRow({ globalStatus: this.globalStatus, test: item })
            })
          }
        }
        .scrollable(ScrollDirection.Vertical)
        .height("60%")

        Row() {
          TextArea({ text: this.message })
            .width('95%')
            .height('20%')
            .padding('1%')
            .fontSize(10)
            .margin({ top: 20 })

          // Text(this.message)
          //   .fontSize(20)
          //   .padding('2%')
        }

        Row() {
          if (this.globalStatus == Status.Idle) {
            Select(this.cpuOptions)
              .value("Core affinity")
              .width('40%')
              .enabled(this.globalStatus == Status.Idle)
              .onSelect((index: number, text?: string | undefined) => {
                if (index >= this.cpuCount)
                  this.currentCpuSelection = -1;
                this.currentCpuSelection = index;
              })
          }

          if (this.globalStatus != Status.Completed) {
            Button("Run")
              .fontSize(this.sz)
              .fontWeight(FontWeight.Bold)
              .onClick(async () => {
                this.globalStatus = Status.Running;

                this.testList.forEach(item => {
                  if (item.checked)
                    item.status = Status.Pending
                  else item.status = Status.Skipped
                })

                let idToRun = this.testList.filter(item => item.checked)
                  .map(item => item.id)
                runTestList(idToRun, this.currentCpuSelection, this.onStateChange)
                  .then(res => this.globalStatus = Status.Completed)

                // let ret = await runTest(505, this.onStateChange);

              })
              .padding('2%')
              .width('40%')
              .enabled(this.globalStatus == Status.Idle)
          } else {
            Button("Reset")
              .fontSize(this.sz)
              .fontWeight(FontWeight.Bold)
              .onClick(() => {
                this.globalStatus = Status.Idle
                this.message += '\nIdle'
              })
              .padding('2%')
              .width('40%')
              .enabled(this.globalStatus == Status.Completed)
          }
        }
      }
    }.onAppear(async () => {
        this.cpuCount = queryCpuCount()

        for (let i = 0; i < this.cpuCount; ++i) {
          this.cpuOptions.push({ value: i.toString() })
        }

        this.globalStatus = Status.Running

      hilog.info(0x0000, 'testTag', 'extracting payload...')
      let res = await resourceFile('spec_payload.zip')
        this.path = res
        hilog.info(0x0000, 'testTag', 'payload path: %{public}s', this.path)

        await decompressBundle('spec_payload.zip')
        await (async () => {this.globalStatus = Status.Idle})();


        // Keep screen always on
        let windowClass = await window.getLastWindow(this.context)
        await windowClass.setWindowKeepScreenOn(true)
    })
  }
}


@Component
struct TestRow {
  @Prop globalStatus: Status;
  @ObjectLink test: TestItem;

  statusText = () => {
    switch (this.test.status) {
      case Status.Pending:
        return "Pending";
      case Status.Initializing:
        return "Initializing...";
      case Status.Running:
        return `Running...${this.test.errmsg}`;
      case Status.Completed:
        if (this.test.type != TestType.Other)
          return `${this.test.reftime.toFixed(0)} / ${this.test.time.toFixed(2)} = ${this.test.score.toFixed(2)}pts`
        else return "Completed"
      case Status.Error:
        return `Error: ${this.test.errmsg}`
      case Status.Skipped:
        return "Skipped";
      default:
        return "---";
    }
  }

  statusFontColor = () => {
    if (this.globalStatus == Status.Idle)
      return 0x000000;
    switch (this.test.status) {
      case Status.Skipped:
        return 0xCCCCCC;
      default:
        return 0x000000;
    }
  }

  statusFontWeight = () => {
    if (this.globalStatus == Status.Idle) {
      return this.test.checked ? FontWeight.Bold : FontWeight.Normal;
    }
    return (this.test.status == Status.Initializing || this.test.status == Status.Running) ? FontWeight.Bold : FontWeight.Normal;
  }

  build() {
    Row() {
      Text(this.test.name)
        .fontSize(20)
        .fontWeight(this.statusFontWeight())
        .fontColor(this.statusFontColor())
        .onClick(() => this.test.checked = !this.test.checked)
      if (this.globalStatus != Status.Idle) {
        Text(this.statusText())
          .fontSize(15)
          .fontWeight(this.statusFontWeight())
          .fontColor(this.statusFontColor())
          .padding('1%')
      }

      if (this.globalStatus == Status.Idle) {
        Checkbox({ group: testTypeToString(this.test.type) })
          .select($$this.test.checked)
      }
    }
    .padding('2%')
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
