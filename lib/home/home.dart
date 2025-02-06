import 'package:flutter/material.dart';
import '../Themes/themes.dart';
import '../Themes/path.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0.0),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: const CarouselPanel(),
    );
  }
}

class CarouselPanel extends StatefulWidget {
  const CarouselPanel({super.key});

  @override
  State<CarouselPanel> createState() => _CarouselPanelState();
}

class _CarouselPanelState extends State<CarouselPanel> {
  final CarouselController controller = CarouselController(initialItem: 1);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200),
      child: CarouselView(
        itemExtent: 330,
        shrinkExtent: 200,
        padding: const EdgeInsets.all(10.0),
        children: List.generate(
          home_carousel_images.length,
          (index) => Image.asset(
            home_carousel_images[index],
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
