#if os(watchOS)
import WidgetKit
import SwiftUI

@main
struct ThundraComplicationBundle: WidgetBundle {
  var body: some Widget {
    ThundraComplication()
  }
}
#endif
