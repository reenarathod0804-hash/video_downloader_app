import 'package:flutter/material.dart';

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  List<String> name = ['1st page', '2nd pages', '3rd page'];
  PageController pageController = PageController();
  int currentIndex=0;
  void pageChange(int index){
    setState(() {

      currentIndex=index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
              child: PageView.builder(
            controller: pageController,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Text(name[index]),
                ],
              );
            },
                onPageChanged: (value){
              pageChange(value);
                },
          )
          ),
          Column(
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      3,
                      (index) => AnimatedContainer(
                            margin: EdgeInsets.all(1),
                        height: 5,
                        width: currentIndex==index ? 50:30,
                        decoration: BoxDecoration(
                          color: currentIndex==index ? Colors.orange : Colors.grey,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        curve: Curves.easeIn,
                        duration: Duration(microseconds: 100),

                      )))
            ],
          ),
          SizedBox(height: 100,)
        ],
      ),
    );
  }
}
