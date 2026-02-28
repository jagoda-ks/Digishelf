import 'package:flutter/material.dart';
import 'shelf.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digishelf',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ShelfPage(title: 'Digishelf'),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'shelf.dart';

// void main() {
//   runApp(const PixelatedRoot());
// }

// class PixelatedRoot extends StatelessWidget {
//   const PixelatedRoot({super.key});

//   // Lower = more pixelated
//   static const double scale = 0.12;

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         body: LayoutBuilder(
//           builder: (context, constraints) {
//             return OverflowBox(
//               maxWidth: double.infinity,
//               maxHeight: double.infinity,
//               child: Transform.scale(
//                 scale: 1 / scale,
//                 alignment: Alignment.topLeft,
//                 child: RepaintBoundary(
//                   child: SizedBox(
//                     width: constraints.maxWidth * scale,
//                     height: constraints.maxHeight * scale,
//                     child: const MyApp(),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const ShelfPage(title: 'Digishelf');
//   }
// }