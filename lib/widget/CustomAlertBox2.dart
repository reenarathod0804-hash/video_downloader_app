import 'package:flutter/material.dart';
import 'package:video_dloader/configue/constant/AppColors.dart';
import 'package:video_dloader/widget/CustomElevatedButton.dart';

class CustomAlertBox2 extends StatelessWidget {
  final String? title;
  final TextEditingController? controller;
  final String? buttonText1;
  final String? buttonText2;
  final ValueChanged? onChange;
  final VoidCallback? onTap;

  const CustomAlertBox2({
    super.key,
    this.title,
    this.buttonText1,
    this.buttonText2,
    this.controller,
    this.onChange,
    this.onTap,
  });

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
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.textField,
                  ),
                  child: TextField(
                    style: Theme.of(context).textTheme.labelSmall,
                    onChanged: onChange,
                    controller: controller,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 16,horizontal: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        onTap: () {
                          Navigator.pop(context);
                        },
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
                        onTap: onTap,
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
