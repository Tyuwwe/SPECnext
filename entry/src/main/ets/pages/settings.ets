import deviceInfo from "@ohos.deviceInfo"
import { queryCpuCount } from 'libentry.so';
import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';

interface settingsType {
  ncopies: number,
  currentCpuSelection: number
}

@Component
export struct settings {
  @State barStyle: BarStyle = BarStyle.STANDARD;
  cpuCount: number = 0;
  @State cpuOptions: Array<SelectOption> = [];
  @State settingsData: settingsType = {
    ncopies: 1,
    currentCpuSelection: -1
  }
  pageInfo: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      Column() {
        Stack() {
          Row()
            .backgroundColor('rgb(245, 245, 245)')
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
            Text(`${deviceInfo.marketName}`)
              .fontSize(24)
              .fontWeight(FontWeight.Bolder)
            Text(`Harmony OS ${deviceInfo.majorVersion}.${deviceInfo.seniorVersion}.${deviceInfo.featureVersion}`)
              .fontSize(16)
            Text(`${this.cpuCount} Cores Available`)
              .fontSize(16)
              .lineHeight(8)
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
              TextInput({ text: String(this.settingsData.ncopies) })
                .width('50%')
                .onChange((value: string) => {
                  this.settingsData.ncopies = parseInt(value)
                })
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
            }
            .width('100%')

            Row() {
              Button('Clear Benchmark History')
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
            .fontColor('rgb(200, 200, 200)')
          Text('@Swung0x48')
            .fontSize(12)
            .fontColor('rgb(200, 200, 200)')
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
            .fontColor('rgb(200, 200, 200)')
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
    .onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack
      this.cpuCount = queryCpuCount()

      for (let i = 0; i < this.cpuCount; ++i) {
        this.cpuOptions.push({ value: i.toString() })
      }
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