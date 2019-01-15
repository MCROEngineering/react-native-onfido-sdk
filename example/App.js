/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React, {Component} from 'react';
import {StyleSheet, Text, View, TouchableOpacity, Modal} from 'react-native';
import RNOnfidoSdk from 'react-native-onfido-sdk';

import DocumentTypesSelector from './src/DocumentTypesSelector';

const data = [{
  id: 0,
  title: 'Start default flow'
}, {
  id: 2,
  title: 'Start flow with custom document types'
}];

const mobileSdkToken = 'test_rt3PKCL3iy2N1AUQzM0mNT5DlqhnW-w2';
const applicantId = 'test';

const defaultParams = {
  token: mobileSdkToken,
  applicantId
};

export default class App extends Component {

  state = {
    documentTypesSelectorVisible: false
  };

  _onfidoSuccessResponse = () => {

  };

  _onfidoErrorResponse = () => {

  };

  _onItemPress = (item) => {
    switch (item.id) {
      case 0:
        RNOnfidoSdk.startSDK(defaultParams, this._onfidoSuccessResponse, this._onfidoErrorResponse);
        break;
      case 2:
        this.setState({ documentTypesSelectorVisible: true });
        break;
      default: break;
    }
  };

  _onDocumentTypesSelected = (selections) => {
    this.setState({ documentTypesSelectorVisible: false }, () => {
      setTimeout(() => {
        const params = {
          ...defaultParams,
          documentTypes: selections.map(s => s.docType)
        };
        RNOnfidoSdk.startSDK(params, this._onfidoSuccessResponse, this._onfidoErrorResponse);
      })
    })
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
        <Modal visible={this.state.documentTypesSelectorVisible} transparent>
          <DocumentTypesSelector
            onDismiss={() => this.setState({ documentTypesSelectorVisible: false })}
            onSelect={this._onDocumentTypesSelected}
          />
        </Modal>
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
