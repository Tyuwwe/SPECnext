import deviceInfo from "@ohos.deviceInfo"
import common from '@ohos.app.ability.common'
import Want from '@ohos.app.ability.Want'
import { fileIo as fs } from '@kit.CoreFileKit';
import { vibrator } from '@kit.SensorServiceKit';

const clearAllHistoryFiles = async () => {
  const path = `${getContext().filesDir}/benchmark_history`

  await fs.rmdir(path)
  console.log('HISTORY: History Deleted')

  await fs.mkdir(path)
  console.log('HISTORY: History Path Created')
}

@Component
export struct settings {
  @State barStyle: BarStyle = BarStyle.STANDARD;
  @StorageLink('nCopies') nCopies: number | undefined = AppStorage.get('nCopies');
  @StorageLink('debugMode') debugMode: boolean | undefined = AppStorage.get('debugMode');
  pageInfo: NavPathStack = new NavPathStack()

  @Builder
  deleteConfirm() {
    Column({ space: 8 }) {
      Row({ space: 4 }) {
        SymbolGlyph($r('sys.symbol.exclamationmark_triangle_fill'))
        Text('Delete all records?')
      }
      .width(200)
      .justifyContent(FlexAlign.Start)
      Row() {
        Button('Yes')
          .width('49%')
          .controlSize(ControlSize.SMALL)
          .onClick(() => {
            clearAllHistoryFiles()
          })
        Button('No')
          .controlSize(ControlSize.SMALL)
          .width('49%')
          .role(ButtonRole.ERROR)
      }
      .width(200)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .padding(12)
  }

  build() {
    NavDestination() {
      Column() {
        Stack() {
          Row()
            .backgroundColor($r('sys.color.background_secondary'))
            .width('100%')
            .height(300)
            .borderRadius({
              bottomLeft: '100%',
              bottomRight: '100%'
            })
          Column({ space: 12 }) {
            Image($r('app.media.ic_public_devices_phone'))
              .size({ width: '25%', height: undefined })
              .autoResize(true)
              .fillColor($r('sys.color.font_primary'))
            Text(`${deviceInfo.marketName}`)
              .fontSize(24)
              .fontWeight(FontWeight.Bolder)
            Text(`Harmony OS ${deviceInfo.majorVersion}.${deviceInfo.seniorVersion}.${deviceInfo.featureVersion}`)
              .fontSize(16)
          }
          .height(300)
          .justifyContent(FlexAlign.Center)
        }
        .height(300)
        .alignContent(Alignment.Top)
        Scroll() {
          Column({ space: 12 }) {
            Row() {
              Text('n Copies')
              TextInput({ text: `${this.nCopies}` })
                .type(InputType.Number)
                .width('50%')
                .onChange((value: string) => {
                  this.nCopies = parseInt(value)
                })
                .onEditChange((state: boolean) => {
                  if (!state && !this.nCopies) {
                    this.nCopies = 1
                  }
                })
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              Text('Debug Mode')
              Toggle({
                type: ToggleType.Switch,
                isOn: $$this.debugMode
              })
                .onClick(() => {
                  vibrator.startVibration({
                    type: 'preset',
                    effectId: 'haptic.notice.success',
                    count: 1,
                  }, {
                    usage: 'notification'
                  })
                })
                .height(24)
                .width(48)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              Button('Reload Assets')
                .width('100%')
                .buttonStyle(ButtonStyleMode.NORMAL)
                .type(ButtonType.Capsule)
                .role(ButtonRole.NORMAL)
                .enabled(false)
            }
            .width('100%')

            Row() {
              Button('Clear Benchmark History')
                .bindMenu(this.deleteConfirm)
                .width('100%')
                .buttonStyle(ButtonStyleMode.NORMAL)
                .type(ButtonType.Capsule)
                .role(ButtonRole.ERROR)
            }
            .width('100%')
          }
          .width('90%')
        }
        .margin({ top: 24 })

        Row({ space: 8 }) {
          Text('Contributors:')
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
          Text('@Swung0x48')
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
            .onClick(() => {
              try {
                let want:Want = {
                  action: 'ohos.want.action.viewData',
                  entities: ['entity.system.browsable'],
                  uri: 'https://github.com/Swung0x48'
                }
                let context = getContext(this) as common.UIAbilityContext;
                context.startAbility(want)
                console.info(`explicit start ability succeed`)
              } catch (error) {
                console.info(`explicit start ability failed with ${error.code}`)
              }
            })
          Text('@Tyuwwe')
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
            .onClick(() => {
              try {
                let want:Want = {
                  action: 'ohos.want.action.viewData',
                  entities: ['entity.system.browsable'],
                  uri: 'https://github.com/Tyuwwe'
                }
                let context = getContext(this) as common.UIAbilityContext;
                context.startAbility(want)
                console.info(`explicit start ability succeed`)
              } catch (error) {
                console.info(`explicit start ability failed with ${error.code}`)
              }
            })
        }
        .margin({ top: 12 })
      }
    }
    .onReady(async (context: NavDestinationContext) => {
      this.pageInfo = context.pathStack
    })
    .title(
      {
        main: 'Settings',
        sub: 'SPECnext'
      },
      {
        backgroundBlurStyle: BlurStyle.COMPONENT_THICK,
        barStyle: this.barStyle,
      }
    )
  }
}

@Builder
export function settingsBuilder(name: string, param: Object) {
  settings()
}