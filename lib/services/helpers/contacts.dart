import 'package:app_settings/app_settings.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/services/api/socket/socket.dart';
import 'package:indigo24/services/db/contact/contact_model.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/widgets/alerts/indigo_alert.dart';
import 'package:indigo24/widgets/alerts/indigo_show_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

import 'formatter.dart';

List<MyContact> myContacts = [];

class IndigoContacts {
  static getContactsTemplate(context) async {
    return await IndigoContacts.getContacts().then((getContactsResult) {
      var result = getContactsResult is List ? false : !getContactsResult;

      for (int i = 0; i < getContactsResult.length; i++) {
        ChatRoom.shared.userCheck(getContactsResult[i]['phone']);
      }

      if (result) {
        showIndigoDialog(
          context: context,
          builder: CustomDialog(
            description: Localization.language.allowContacts,
            yesCallBack: () {
              Navigator.pop(context);
              AppSettings.openAppSettings();
            },
            noCallBack: () {
              Navigator.pop(context);
            },
          ),
        );
      }
    });
  }

  static getContacts({bool withThumbnails}) async {
    var contacts = [];
    try {
      contacts.clear();
      if (await Permission.contacts.request().isGranted) {
        Iterable<Contact> phonebook =
            await ContactsService.getContacts(withThumbnails: false);
        if (phonebook != null) {
          phonebook.forEach((el) {
            if (el.displayName != null) {
              el.phones.forEach((phone) {
                if (!contacts.contains(Formatter.formatPhone(phone.value))) {
                  phone.value = Formatter.formatPhone(phone.value);
                  if (contacts.every((user) => user['phone'] != phone.value)) {
                    contacts.add({
                      'name': el.displayName,
                      'phone': phone.value,
                      'label': phone.label,
                    });
                  }
                }
              });
            }
          });
        }
        return contacts.toSet().toList();
      } else {
        return false;
      }
    } catch (_) {
      print(_);
      return "disconnect";
    }
  }

  static search(String query) {
    List<dynamic> matches = List<dynamic>();

    myContacts.forEach((item) {
      if (item.name != null && item.phone != null) {
        if (item.name.toString().toLowerCase().contains(query.toLowerCase()) ||
            item.phone.toString().toLowerCase().contains(query.toLowerCase())) {
          matches.add(item);
        }
      }
    });
    return matches;
  }
}
