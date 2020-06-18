import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_homie/bloc/mqtt_setting.dart';
import 'package:flutter_homie/bloc/mqtt_settings_bloc.dart';
import 'package:flutter_homie/data/model/settings_model.dart';

import '../../dependency_injection.dart';

const InputDecoration _decoration = InputDecoration(
  border: const OutlineInputBorder(),
  contentPadding: EdgeInsets.all(12.0),
);

class MqttSettingsScreen extends StatelessWidget {
  MqttSettingsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Mqtt Settings'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.save),
              tooltip: 'Save',
              onPressed: () {
                var _fbKey = getIt<MqttSettingsBloc>().formKey;
                if (_fbKey.currentState.saveAndValidate()) {
                  getIt<MqttSettingsBloc>().add(MqttSettingsEvent.retrieved(SettingsModel.fromJson(_fbKey.currentState.value)));
                  Navigator.of(context).pop();
                }
              },
            )
          ],
        ),
        body: BlocBuilder<MqttSettingsBloc, MqttSettingsState>(
          bloc: getIt<MqttSettingsBloc>(),
          builder:(context, state) => FormBuilder(
            key: getIt<MqttSettingsBloc>().formKey,
            autovalidate: true,
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.dns),
                  title: Text('Mqtt Server'),
                ),
                ListTile(
                  title: Row(
                    children: <Widget>[
                      Flexible(
                        flex: 3,
                        child: FormBuilderTextField(
                          initialValue: state.maybeWhen(orElse: () => '127.0.0.1', available: (model) => model.mqttIp),
                          attribute: 'baseUrl',
                          decoration: _decoration.copyWith(labelText: 'MQTT url'),
                          keyboardType: TextInputType.url,
                          validators: [
                            FormBuilderValidators.required(),
                            FormBuilderValidators.url()
                          ],
                          autocorrect: false,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Flexible(
                        flex: 1,
                        child: FormBuilderTextField(
                          attribute: 'port',
                          decoration: _decoration.copyWith(labelText: 'Port'),
                          initialValue:  state.maybeWhen(orElse: () => '1883', available: (model) => model.mqttPort.toString()),
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          validators: [
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                            FormBuilderValidators.min(0),
                            FormBuilderValidators.max(65535),
                          ],
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly,
                          ],
                          valueTransformer: (value) => int.tryParse(value ?? 80),
                        ),
                      )
                    ],
                  ),
                ),
                ListTile(
                  title: FormBuilderTextField(
                    initialValue: state.maybeWhen(orElse: () => 'Homie-Device-Discovery-App', available: (model) => model.mqttClientId),
                    attribute: 'clientID',
                    decoration: _decoration.copyWith(labelText: 'MQTT ClientID'),
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    maxLines: 1,
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
