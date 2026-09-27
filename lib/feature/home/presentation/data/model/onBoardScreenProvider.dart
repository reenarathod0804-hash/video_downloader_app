import 'package:flutter/cupertino.dart';

class OnBoardProvider with ChangeNotifier {
    final PageController pageController=PageController();
    int currentIndex=0;
    void changePage(int index){
      currentIndex=index;
      notifyListeners();
    }


}