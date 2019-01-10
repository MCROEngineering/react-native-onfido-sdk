/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React, {Component} from 'react';
import {StyleSheet, Text, View, TouchableOpacity} from 'react-native';
import RNOnfidoSdk from 'react-native-onfido-sdk';

const data = [{
  id: 0,
  title: 'Start default flow'
}, {
  id: 1,
  title: 'Start flow with single document type'
}, {
  id: 2,
  title: 'Start flow with custom document types'
}];

const mobileSdkToken = 'test_rt3PKCL3iy2N1AUQzM0mNT5DlqhnW-w2';

const applicantId = 'test';

export default class App extends Component {

  _onfidoSuccessResponse = () => {

  };

  _onfidoErrorResponse = () => {

  };

  _onItemPress = (item) => {
    const params = {
      token: mobileSdkToken,
      applicantId,
      documentTypes: [RNOnfidoSdk.DocumentTypeResidencePermit, RNOnfidoSdk.DocumentTypePassport, RNOnfidoSdk.DocumentTypeNationalIdentityCard],
      withWelcomeScreen: false // android only
    };

    switch (item.id) {
      case 0:
        break;
      case 1:
        break;
      case 2:
        break;
      default: break;
    }

    RNOnfidoSdk.startSDK(params, this._onfidoSuccessResponse, this._onfidoErrorResponse);
  };

  _renderItem = item => (
    <TouchableOpacity key={item.id} style={styles.listItem} onPress={() => this._onItemPress(item)}>
      <Text style={styles.listItemText}>{item.title}</Text>
    </TouchableOpacity>
  );

  render() {
    return (
      <View style={styles.container}>
        {data.map(this._renderItem)}
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  listItem: {
    padding: 24,
  },
  listItemText: {
    textAlign: 'center',
    fontSize: 20,
    color: '#2675ff',
  },
});
