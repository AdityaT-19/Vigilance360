import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vigilance_360/app/controllers/mqtt_controller.dart';
import 'package:vigilance_360/app/views/home_screen.dart';

class ChangePass extends StatelessWidget {
  ChangePass({super.key});
  final cont = Get.find<MqttController>();
  final TextEditingController _newPass = TextEditingController();
  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Change Password',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Form(
          key: _key,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: EdgeInsets.all(
                  Get.width * 0.1,
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  controller: _newPass,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 4) {
                      return 'Password must be 4 digits';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    _newPass.text = newValue!;
                  },
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Get.theme.colorScheme.primary,
                  foregroundColor: Get.theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: Get.width * 0.1,
                    vertical: Get.height * 0.02,
                  ),
                ),
                onPressed: () async {
                  if (_key.currentState!.validate()) {
                    _key.currentState!.save();
                    cont.changePassword(_newPass.text);
                    Get.snackbar(
                      'Password Changed',
                      'Password changed successfully',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    await Future.delayed(const Duration(seconds: 1));
                    Get.off(HomeScreen());
                  }
                },
                label: Text(
                  'Change Password',
                  style: Get.theme.textTheme.headlineMedium!.copyWith(
                    color: Get.theme.colorScheme.onPrimary,
                  ),
                ),
                icon: const Icon(Icons.lock),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
