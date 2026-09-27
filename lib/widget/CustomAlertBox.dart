import 'package:flutter/material.dart';
import 'package:video_dloader/widget/CustomElevatedButton.dart';

class CustomAlertBox extends StatelessWidget {
  final String? title;
  final String? desc;
  final String? buttonText1;
  final String? buttonText2;
  final String? hintText;
  final VoidCallback? onTap1;
  final VoidCallback? onTap2;

  const CustomAlertBox(
      {super.key,
      this.title,
      this.desc,
      this.buttonText1,
      this.buttonText2,
      this.hintText,
      this.onTap1,
      this.onTap2});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)), //this right here
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: size.height * 0.02,
                ),
                Text(
                  title ?? '',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Text(
                  desc ?? '',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        onTap: onTap1,
                        height: 40,
                        borderRadius: BorderRadius.circular(5),
                        buttonText: buttonText1,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.01,
                    ),
                    Expanded(
                      child: CustomElevatedButton(
                        onTap: onTap2,
                        height: 40,
                        borderRadius: BorderRadius.circular(5),
                        buttonText: buttonText2,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
              ],
            ),
          ),
        ),
      );
  }
}
