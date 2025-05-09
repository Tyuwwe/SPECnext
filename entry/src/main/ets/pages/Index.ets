import { hilog } from '@kit.PerformanceAnalysisKit';
import testNapi from 'libentry.so';
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

async function runTestList(testList: Array<number>, func: object) {
  return new Promise<number>((resolve, reject) => {
    let ret = testNapi.runTests(testList, 19, func);
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
  INT,
  FP
}

enum Status {
  Skipped = 0,
  Pending,
  Initializing,
  Running,
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
  path: string = "";
  @State refreshCount: number = 0;
  @State globalStatus: Status = Status.Idle;

  private context: common.BaseContext = getContext(this) as common.BaseContext

  @State testList: Array<TestItem> = [
    // INT
    new TestItem('500.perlbench_r', TestType.INT, false, Status.Skipped, 1592, -1, -1, ""),
    new TestItem('502.gcc_r',       TestType.INT, false, Status.Skipped, 1416, -1, -1, ""),
    new TestItem('505.mcf_r',       TestType.INT, false, Status.Skipped, 1616, -1, -1, ""),
    new TestItem('520.omnetpp_r',   TestType.INT, false, Status.Skipped, 1312, -1, -1, ""),
    new TestItem('523.xalancbmk_r', TestType.INT, false, Status.Skipped, 1056, -1, -1, ""),
    new TestItem('525.x264_r',      TestType.INT, false, Status.Skipped, 1751, -1, -1, ""),
    new TestItem('531.deepsjeng_r', TestType.INT, false, Status.Skipped, 1146, -1, -1, ""),
    new TestItem('541.leela_r',     TestType.INT, false, Status.Skipped, 1656, -1, -1, ""),
    new TestItem('548.exchange2_r', TestType.INT, false, Status.Skipped, 2620, -1, -1, ""),
    new TestItem('557.xz_r',        TestType.INT, false, Status.Skipped, 1080, -1, -1, ""),

    // FP
    new TestItem('503.bwaves_r',    TestType.FP, false, Status.Skipped, 10028, -1, -1, ""),
    new TestItem('507.cactuBSSN_r', TestType.FP, false, Status.Skipped, 16670, -1, -1, ""),
    new TestItem('508.namd_r',      TestType.FP, false, Status.Skipped, 950,   -1, -1, ""),
    new TestItem('510.parest_r',    TestType.FP, false, Status.Skipped, 2616,  -1, -1, ""),
    new TestItem('511.povray_r',    TestType.FP, false, Status.Skipped, 2335,  -1, -1, ""),
    new TestItem('519.lbm_r',       TestType.FP, false, Status.Skipped, 1054,  -1, -1, ""),
    new TestItem('521.wrf_r',       TestType.FP, false, Status.Skipped, 2240,  -1, -1, ""),
    new TestItem('526.blender_r',   TestType.FP, false, Status.Skipped, 1523,  -1, -1, ""),
    new TestItem('527.cam4_r',      TestType.FP, false, Status.Skipped, 8863,  -1, -1, ""),
    new TestItem('538.imagick_r',   TestType.FP, false, Status.Skipped, 2487,  -1, -1, ""),
    new TestItem('544.nab_r',       TestType.FP, false, Status.Skipped, 1683,  -1, -1, ""),
    new TestItem('549.fotonik3d_r', TestType.FP, false, Status.Skipped, 3897,  -1, -1, ""),
    new TestItem('554.roms_r',      TestType.FP, false, Status.Skipped, 1103,  -1, -1, ""),
  ];


  onStateChange = async (newStatus: Status, test: number, time: number, errmsg: string) => {
    const TEST_GLOBAL = -1
    // this.message = message

    if (test == TEST_GLOBAL) {
      this.globalStatus = newStatus
      switch (newStatus) {
        case Status.Initializing:
          this.message += "\n"
          this.message += "Initializing..."
          return
        case Status.Error:
          this.message += "\n"
          this.message += "Failed with error: " + errmsg
          break
        case Status.Completed:
          this.message += "\n"
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
    this.testList[idx].errmsg = errmsg

    switch (newStatus) {
      case Status.Initializing:
        this.message += "\n"
        this.message += "Setting up " + this.testList[idx].name + "..."
        break
      case Status.Running:
        this.message += "\n"
        this.message += "Running " + this.testList[idx].name + "..."
        break
      case Status.Completed:
          this.message += "\n"
          this.message += this.testList[idx].name + " completed, elapsed " + time.toFixed(2) + "s."
          this.testList[idx].time = time
          this.testList[idx].score = this.testList[idx].reftime / time
        break
      case Status.Error:
        this.message += "\n"
        this.message += this.testList[idx].name + " failed with: " + errmsg
        break
      case Status.Idle:
        this.message += "\n"
        this.message += "Idle"
        break
      default:
        this.message += "\n"
        this.message += "Unknown"
        break
    }
    // this.message = "state: " + status + ", " + test.toString() + ", msg: " + message
  }

  build() {
    Row() {
      Column() {
        Row() {
          Column() {
            CheckboxGroup({ group: "INT_Test" })
              .enabled(this.globalStatus == Status.Idle)
            Text("INT")
          }.padding({ left: '2%', right: '2%' })
          Column() {
            CheckboxGroup({ group: "FP_Test" })
              .enabled(this.globalStatus == Status.Idle)
            Text("FP")
          }.padding({ left: '2%', right: '2%' })
        }
        Scroll() {
          Column() {
            Text('INT')
              .fontSize(15)
              .fontColor(0xCCCCCC)
              .width('100%')
              .padding('2%')
              .textAlign(TextAlign.Start)
            Divider().strokeWidth(3).color('#F1F3F5')
            ForEach(this.testList, (item: TestItem) => {
              if (item.type == TestType.INT)
                TestRow({ globalStatus: this.globalStatus, test: item })
            })

            Text('FP')
              .fontSize(15)
              .fontColor(0xCCCCCC)
              .width('100%')
              .padding('2%')
              .textAlign(TextAlign.Start)
            Divider().strokeWidth(3).color('#F1F3F5')
            ForEach(this.testList, (item: TestItem) => {
              if (item.type == TestType.FP)
                TestRow({ globalStatus: this.globalStatus, test: item })
            })
          }
        }
        .scrollable(ScrollDirection.Vertical)
        .height("60%")

        Row() {
          TextArea({ text: this.message })
            .width('90%')
            .height('20%')
            .padding('1%')
            .fontSize(20)
            .margin({ top: 20 })

          // Text(this.message)
          //   .fontSize(20)
          //   .padding('2%')
        }

        Row() {
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
                runTestList(idToRun, this.onStateChange)
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
                this.message = 'Idle'
              })
              .padding('2%')
              .width('40%')
              .enabled(this.globalStatus == Status.Completed)
          }

          // Button("Refresh")
          //   .fontSize(this.sz)
          //   .fontWeight(FontWeight.Bold)
          //   .onClick(async () => {
          //     let applicationContext = getContext().getApplicationContext();
          //     let res = testNapi.query()
          //     if (res > 0)
          //       this.message = "505.mcf_r: " + res.toString() + "s"
          //     else {
          //       this.refreshCount++
          //       this.message = "Running 505.mcf_r..., refeshed " + this.refreshCount.toString() + " time(s)."
          //     }
          //   })
          //   .padding('2%')
          //   .width('40%')
        }
      }
    }.onAppear(async () => {
        // let res = await resourceFile('inp.in')
        // this.path = res;
        // hilog.info(0x0000, 'testTag', 'path: %{public}s', this.path)

        let res = await resourceFile('spec_payload.zip')
        this.path = res
        hilog.info(0x0000, 'testTag', 'path: %{public}s', this.path)

        await decompressBundle('spec_payload.zip')

        // Keep screen always on
        let windowClass = await window.getLastWindow(this.context)
        await windowClass.setWindowKeepScreenOn(true)
      // this.isScreenOn = await windowClass.getWindowProperties().isKeepScreenOn
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
        return `${this.test.reftime.toFixed(0)} / ${this.test.time.toFixed(2)} = ${this.test.score.toFixed(2)}pts`
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
        Checkbox({ group: this.test.type == TestType.INT ? "INT_Test" : "FP_Test" })
          .select($$this.test.checked)
      }
    }
    .padding('2%')
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
