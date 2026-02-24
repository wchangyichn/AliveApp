import 'package:alive_app/controllers/alive_controller.dart';
import 'package:alive_app/data/local_event_repository.dart';
import 'package:alive_app/main.dart';
import 'package:alive_app/services/recommendation_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('首页应渲染中文底部导航', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final AliveController controller = AliveController(
      LocalEventRepository(prefs),
      RecommendationService(),
    );
    await controller.initialize();

    await tester.pumpWidget(AliveApp(controller: controller));

    expect(find.text('回忆'), findsOneWidget);
    expect(find.text('足迹'), findsOneWidget);
    expect(find.text('时间线'), findsOneWidget);
    expect(find.text('收藏'), findsOneWidget);
  });
}
