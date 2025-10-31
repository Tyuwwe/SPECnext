@Component
export struct history {
  @State barStyle: BarStyle = BarStyle.STANDARD;
  pageInfo: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      Column() {

      }
    }
    .onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack
    })
    .title(
      {
        main: 'Benchmark History',
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
export function historyBuilder(name: string, param: Object) {
  history()
}