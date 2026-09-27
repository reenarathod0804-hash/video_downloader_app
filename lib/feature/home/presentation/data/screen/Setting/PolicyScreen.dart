import 'package:flutter/material.dart';
import 'package:video_dloader/appExtension.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('Privacy Policy')),
      ),
        body:
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.t('policyDesk'),textAlign: TextAlign.center,),
                SizedBox(height: 10,),
                Text(context.t('1. Information We Collect'),style: TextStyle(fontFamily: 'Niramit Bold', fontSize: 18),
                ),
                Text(context.t('We do not collect personally identifiable information from users. However, the following non-personal data may be collected automatically:')),
                Text(context.t('Device Information:'),style: TextStyle(fontFamily: 'Niramit Bold')),
                Text(context.t('Device model, operating system, unique device identifiers.')),
                Text(context.t('Usage Data:'),style: TextStyle(fontFamily: 'Niramit Bold')),
                Text(context.t('App interactions, error logs, and performance analytics.')),
                Text(context.t('Download Data:'),style: TextStyle(fontFamily: 'Niramit Bold')),
                Text(context.t('Information about downloaded video formats and sources (only for improving app features; not linked to your identity).')),

                SizedBox(height: 10,),
                Text(context.t('2. How We Use Your Information'),style: TextStyle(fontFamily: 'Niramit Bold', fontSize: 18),
                ),
                Text(context.t('We use the collected information to:')),
                Text(context.t('● Improve app functionality and performance.')),
                Text(context.t('● Fix bugs and improve user experience.')),
                Text(context.t('● Comply with legal obligations.')),
                SizedBox(height: 10,),
                Text(context.t('3. Third-Party Services'),style: TextStyle(fontFamily: 'Niramit Bold', fontSize: 18),
                ),
                Text(context.t('Our app may use third-party tools such as:')),
                Text(context.t('● Analytics (e.g., Google Firebase Analytics)')),
                Text(context.t('● Advertising networks (e.g., Google AdMob)')),
                SizedBox(height: 10,),
                Text(context.t('4. Data Sharing'),style: TextStyle(fontFamily: 'Niramit Bold', fontSize: 18),
                ),
                Text(context.t('We do not sell, trade, or rent your personal information to others. Data may be shared only:')),
                SizedBox(height: 10,),
                Text(context.t('5. Security'),style: TextStyle(fontFamily: 'Niramit Bold', fontSize: 18),
                ),
                Text(context.t('We implement reasonable security measures to protect your data. However, no method of transmission over the internet is 100% secure.')),
                SizedBox(height: 10,),
                Text(context.t('6. User Control'),style: TextStyle(fontFamily: 'Niramit Bold', fontSize: 18),
                ),
                Text(context.t('Since we do not store personal data, you are not required to register or submit any information. You can uninstall the app at any time to stop all data collection.')),
                
                SizedBox(height: 50,),
              ],
            ),
          ),
        )
    );
  }
}
