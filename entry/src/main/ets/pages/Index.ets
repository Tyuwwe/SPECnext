import { hilog } from '@kit.PerformanceAnalysisKit';
import testNapi, { queryCpuCount } from 'libentry.so';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import window from '@ohos.window';
import { zlib, BusinessError } from '@kit.BasicServicesKit';
import deviceInfo from '@ohos.deviceInfo';
import { SymbolGlyphModifier } from '@kit.ArkUI';

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

  const destPath = cwd + "/refdata"

  const exists = fs.accessSync(destPath)
  if (exists) {
    fs.rmdirSync(destPath)
  }
  fs.mkdirSync(destPath)

  const bundlePath = cwd + '/' + fileName
  await zlib.decompressFile(bundlePath, destPath)
  await fs.listFile(destPath).then((filenames: Array<string>) => {
    console.info("listFile decompressBundle succeed");
    for (let i = 0; i < filenames.length; i++) {
      console.info("fileName: %s", destPath + '/' + filenames[i]);
    }
  })
}

const TEST_GLOBAL = -1

async function runTestList(testList: Array<TestItem>, cpu: number, ncopies: number, func: Function) {
  // Show preflight message
  let msg =
    "Preflight check:\n" +
      `affinity = ${cpu}\n` +
      `copies = ${ncopies}\n` +
      `tests = [`

  for (let test of testList) {
    msg += (test.name + ", ")
  }
  msg += "]\n"

  func(Status.Message, TEST_GLOBAL, 0, msg)

  // Set up tests
  func(Status.Message, TEST_GLOBAL, 0, `Setting up tests...`)

  const cwd = getContext().filesDir
  const srcPath = cwd + "/refdata"

  try {
    const rundir = cwd + "/run";
    const exists = await fs.access(rundir)
    if (exists) {
      await fs.rmdir(rundir)
    }
    await fs.mkdir(rundir)

    const srcExists = await fs.access(srcPath)
    if (!srcExists)
      throw Error("src not exist")
  } catch (err) {
    func(Status.Message, TEST_GLOBAL, 0, `Setup run dir failed: ${err}`)
  }

  for (let i = 0; i < ncopies; ++i) {
    const curRunDir = `${cwd}/run/${i}`
    await fs.mkdir(curRunDir)
    for (let test of testList) {
      const localSrcPath = `${srcPath}/${test.name}`
      const localDstPath = curRunDir
      try {
        await fs.copyDir(localSrcPath, localDstPath, 1)
      } catch (err) {
        func(Status.Message, TEST_GLOBAL, 0, `Copy #${i}: ${test.name} failed: ${err}`)
        return new Promise<number>((res, rej) => {
          rej(err)
        })
      }
      func(Status.Message, TEST_GLOBAL, 0, `Setup Copy #${i}: ${test.name} completed.`)
    }

    // await fs.listFile(curRunDir + "/500.perlbench_r").then((filenames: Array<string>) => {
    //   console.info(`ls ${curRunDir}/500.perlbench_r`);
    //   for (let i = 0; i < filenames.length; i++) {
    //     console.info("fileName: %s",  `${filenames[i]}`);
    //   }
    // })
  }

  func(Status.Message, TEST_GLOBAL, 0, `Initiating tests...`)
  // Run tests
  return new Promise<number>((resolve, reject) => {
    let ret = testNapi.runTests(testList.map(test => test.id), cpu, ncopies, func);
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
      return "INT(Rate)"
    case TestType.FPrate:
      return "FP(Rate)"
    case TestType.INTspeed:
      return "INT(Speed)"
    case TestType.FPspeed:
      return "FP(Speed)"
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
  @State sz: number = 20;
  cpuCount: number = 0;
  @State cpuOptions: MenuElement[] = [];
  @State currentCpuSelection: number = 0;
  @State ncopies: number = 1;
  path: string = "";
  selectTextSize: number = 12
  @State refreshCount: number = 0;
  @State globalStatus: Status = Status.Idle;
  @State barStyle: BarStyle = BarStyle.STANDARD;
  @State activePage: number = 1
  @State bShowLoading: boolean = false
  @State nowSelection: string = 'All'

  errorScroller: Scroller = new Scroller()

  pageInfo: NavPathStack = new NavPathStack()
  @State menuItems:Array<NavigationMenuItem> = [
    {
      value:'history',
      symbolIcon: new SymbolGlyphModifier($r('sys.symbol.arrow_counterclockwise_clock')),
      action: () => {
        this.pageInfo.pushPathByName('History', null)
      }
    },
    {
      value:'setting',
      symbolIcon: new SymbolGlyphModifier($r('sys.symbol.gearshape')),
      action: () => {
        this.pageInfo.pushPathByName('Settings', null)
      }
    },
  ]

  benchTypeOptions: SelectOption[] = [
    {
      value: "All"
    },
    {
      value: "INT(Rate)"
    },
    {
      value: "FP(Rate)"
    },
    {
      value: "INT(Speed)"
    },
    {
      value: "FP(Speed)"
    },
    {
      value: "Other"
    },
  ]

  @Builder
  modalLoading() {
    Column() {
      Text('Benchmark Running')
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 12 })
      Scroll(this.errorScroller) {
        Text(this.message)
          .fontColor('#ff5a5a5a')
          .fontSize(12)
      }
      .width('90%')
      .height('50%')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

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
    new TestItem('9997.llama-server',TestType.Other, false, Status.Skipped, 1,  -1, -1, ""),
    new TestItem('9998.c2clat',      TestType.Other, false, Status.Skipped, 1,  -1, -1, ""),
    new TestItem('9999.vkpeak',      TestType.Other, false, Status.Skipped, 1,  -1, -1, ""),
  ];


  onStateChange = async (newStatus: Status, test: number, time: number, msg: string) => {
    // this.message = message

    if (test == TEST_GLOBAL) {
      if (newStatus != Status.Message)
        this.globalStatus = newStatus
      switch (newStatus) {
        case Status.Initializing:
          this.message += "\n"
          this.message += "Initializing..."
          return
        case Status.Message:
          this.message += "\n"
          this.message += msg
          return
        case Status.Error:
          this.message += "\n"
          this.message += "Failed with error: " + msg
          return
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
    this.testList[idx].errmsg = msg

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
          this.testList[idx].time = time
          this.testList[idx].score = this.testList[idx].reftime / time
          this.message += this.testList[idx].name + " completed, elapsed " +
            this.testList[idx].time.toFixed(2) + "s, scored " +
            (this.testList[idx].reftime / time).toFixed(2) + "pts."
        break
      case Status.Error:
        this.message += "\n"
        this.message += this.testList[idx].name + " failed with: " + msg
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
    Navigation(this.pageInfo) {
      Stack() {
        Row() {
          Column() {
            // Header Checkbox
            Row({ space: 8 }) {
              Select(this.benchTypeOptions)
                .value(this.nowSelection)
                .width('calc(100% - 144vp)')
                .onSelect((index, value) => {
                  this.nowSelection = value
                })
              // Remove All Selections
              Button() {
                Row() {
                  SymbolGlyph($r('sys.symbol.trash'))
                    .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
                    .fontColor(['#FFFFFF', '#ffd0d0d0'])
                }
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .width(40)
                .height(40)
              }
              .role(ButtonRole.ERROR)
              .onClick(() => {
                for (let i of this.testList) {
                  i.checked = false
                }
              })
              // Remove Current Type Selection
              Button() {
                Row() {
                  SymbolGlyph($r('sys.symbol.circle_dashed'))
                    .renderingStrategy(SymbolRenderingStrategy.SINGLE)
                    .fontColor([$r('sys.color.warning')])
                }
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .width(40)
                .height(40)
              }
              .buttonStyle(ButtonStyleMode.NORMAL)
              .onClick(() => {
                for (let i of this.testList) {
                  if (this.nowSelection === 'All') {
                    i.checked = false
                  }
                  else if (testTypeToString(i.type) === this.nowSelection) {
                    i.checked = false
                  }
                }
              })
              // Select All Current Type
              Button() {
                Row() {
                  SymbolGlyph($r('sys.symbol.checkmark_circle'))
                    .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
                    .fontColor([$r('sys.color.icon_emphasize'), $r('sys.color.icon_sub_emphasize')])
                }
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .width(40)
                .height(40)
              }
              .buttonStyle(ButtonStyleMode.NORMAL)
              .onClick(() => {
                for (let i of this.testList) {
                  if (this.nowSelection === 'All' || testTypeToString(i.type) === this.nowSelection) {
                    i.checked = true
                  }
                }
              })
            }
            .width('100%')
            .padding(12)
            .justifyContent(FlexAlign.SpaceBetween)
            // Test scroll view
            Scroll() {
              Column() {
                if (this.nowSelection === 'All' || this.nowSelection === 'INT(Rate)') {
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
                }

                if (this.nowSelection === 'All' || this.nowSelection === 'FP(Rate)') {
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
                }

                if (this.nowSelection === 'All' || this.nowSelection === 'INT(Speed)') {
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
                }

                if (this.nowSelection === 'All' || this.nowSelection === 'FP(Speed)') {
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

                }

                if (this.nowSelection === 'All' || this.nowSelection === 'Other') {
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
              .padding({ bottom: '100%' })
            }
            .scrollable(ScrollDirection.Vertical)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring,{alwaysEnabled:true,effectEdge:EffectEdge.END})
            .fadingEdge(true)
            .padding({ bottom: 100 })
          }
        }
        .width('100%')
        .height('100%')
        .onAppear(async () => {
          this.cpuCount = queryCpuCount()

          for (let i = 0; i < this.cpuCount; ++i) {
            this.cpuOptions.push({
              value: `Core ${i}`,
              action: () => {
                this.currentCpuSelection = i
              }
            })
          }

          let res = await resourceFile('spec_payload.zip')
          this.path = res
          hilog.info(0x0000, 'testTag', 'path: %{public}s', this.path)

          this.globalStatus = Status.Pending
          decompressBundle('spec_payload.zip').then(() => {
            this.globalStatus = Status.Idle
          })

          // Keep screen always on
          let windowClass = await window.getLastWindow(this.context)
          await windowClass.setWindowKeepScreenOn(true)
        })

        Column() {
          // TextArea({ text: this.message })
          //   .height('20%')
          //   .padding('28px')
          //   .fontSize(16)
          Row() {
            Row() {
              Text('Core Selection: ')
                .fontWeight(FontWeight.Bold)
              Text(this.cpuOptions[this.currentCpuSelection]?.value)
            }
            Row() {
              Text('n Copies: ')
                .fontWeight(FontWeight.Bold)
              Text(String(this.ncopies))
            }
            // Select(this.cpuOptions)
            //   .value(this.currentCpuSelectionText)
            //   .enabled(this.globalStatus == Status.Idle)
            //   .onSelect((index: number, text: string) => {
            //     if (index >= this.cpuCount)
            //       this.currentCpuSelection = -1;
            //     this.currentCpuSelection = index;
            //     this.currentCpuSelectionText = text
            //   })
            //   .width('100%')
          }
          .padding(12)
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%')

          Row({ space: 8 }) {
            Button() {
              Row() {
                Image($r('app.media.ic_public_chip'))
                  .width(24)
                  .height(24)
              }
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Center)
              .width(40)
              .height(40)
              .bindMenu(this.cpuOptions)
            }
            if (this.globalStatus != Status.Completed) {
              Button("Run")
                .fontSize(this.sz)
                .fontWeight(FontWeight.Bold)
                .onClick(async () => {
                  this.globalStatus = Status.Running;
                  this.bShowLoading = true

                  this.testList.forEach(item => {
                    if (item.checked)
                      item.status = Status.Pending
                    else item.status = Status.Skipped
                  })

                  let testsToRun = this.testList.filter(item => item.checked)
                  // .map(item => item.id)
                  runTestList(testsToRun, this.currentCpuSelection, this.ncopies, this.onStateChange)
                    .then((res) => {
                      this.globalStatus = Status.Completed
                    })
                    .catch(() => {
                      this.bShowLoading = false
                      this.globalStatus = Status.Completed
                    })
                })
                .width('calc(100% - 48vp)')
                .enabled(this.globalStatus == Status.Idle)
            } else {
              Button("Reset")
                .fontSize(this.sz)
                .fontWeight(FontWeight.Bold)
                .onClick(() => {
                  this.globalStatus = Status.Idle
                  this.message += '\nIdle'
                  this.bShowLoading = false
                })
                .width('calc(100% - 48vp)')
                .enabled(this.globalStatus == Status.Completed)
            }
          }
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .bindContentCover(this.bShowLoading, this.modalLoading(), {
          backgroundColor: 'rgba(255, 255, 255, 0.8)',
          modalTransition: ModalTransition.NONE
        })
        .borderRadius({
          topLeft: 20,
          topRight: 20
        })
        .backgroundColor('rgb(255, 255, 255)')
        // .backdropBlur(24)
        .padding('24px')
      }
      .alignContent(Alignment.Bottom)
    }
    .menus(this.menuItems)
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
    .titleMode(NavigationTitleMode.Free)
    .title(
      {
        main: 'SPECnext',
        sub: `${deviceInfo.marketName} / Harmony OS ${deviceInfo.majorVersion}`
      },
      {
        backgroundBlurStyle: BlurStyle.COMPONENT_THICK,
        barStyle: this.barStyle,
      }
    )
  }
}


@Component
struct TestRow {
  @Prop globalStatus: Status;
  @ObjectLink test: TestItem;
  @State rowColor: string = 'rgb(255, 255, 255)'

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

  statusRowBackground = () => {
    if (this.globalStatus == Status.Idle) {
      return this.test.checked ? 'rgb(235, 235, 235)' : 'rgb(255, 255, 255)';
    }
    return (this.test.status == Status.Initializing || this.test.status == Status.Running) ? 'rgb(235, 235, 235)' : 'rgb(255, 255, 255)';
  }

  build() {
      Row() {
        Text(this.test.name)
          .fontSize(18)
          .fontColor(this.statusFontColor())
        if (this.globalStatus != Status.Idle) {
          Text(this.statusText())
            .fontSize(16)
            .fontColor(this.statusFontColor())
            .padding('1%')
        }

        if (this.globalStatus == Status.Idle) {
          Checkbox({ group: testTypeToString(this.test.type) })
            .select($$this.test.checked)
        }
      }
      .onClick(() => {
        this.test.checked = !this.test.checked
      })
      .backgroundColor(this.statusRowBackground())
      .animation({
        duration: 100
      })
      .padding('2%')
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

    }
}
