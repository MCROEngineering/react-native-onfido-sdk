import React from 'react';
import {
  View, Text, StyleSheet, TouchableWithoutFeedback, TouchableOpacity
} from 'react-native';
import RNOnfidoSdk from 'react-native-onfido-sdk';

import DocumentType from './DocumentType';

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.3)',
    justifyContent: 'center',
    alignItems: 'center'
  },
  optionsContainer: {
    width: '90%',
    backgroundColor: 'white',
    borderRadius: 10
  },
  headerTitle: {
    fontSize: 21,
    fontWeight: '700',
    margin: 16
  },
  selectButton: {
    padding: 16,
    justifyContent: 'center',
    alignItems: 'center'
  },
   selectButtonTitle: {
     fontSize: 17,
     fontWeight: '600'
   }
});

const docTypes = [{
  id: 0,
  title: 'Passport',
  docType: RNOnfidoSdk.DocumentTypePassport
}, {
  id: 1,
  title: "Driver's Licence",
  docType: RNOnfidoSdk.DocumentTypeDrivingLicence
}, {
  id: 2,
  title: 'National Identity Card',
  docType: RNOnfidoSdk.DocumentTypeNationalIdentityCard
}, {
  id: 3,
  title: 'Residence Permit Card',
  docType: RNOnfidoSdk.DocumentTypeResidencePermitCard
}];

class DocumentTypesSelector extends React.Component {

  state = {
    selections: []
  };

  _onItemPress = (docType) => {
    const { selections } = this.state;
    const exists = selections.find(s => s.id === docType.id);
    let newSelections = [...selections];

    if (exists) {
      newSelections = newSelections.filter(s => s.id !== docType.id);
    } else {
      newSelections.push(docType);
    }

    this.setState({ selections: newSelections });
  };

  _onSelect = () => {
    if (this.state.selections.length > 0) {
      this.props.onSelect(this.state.selections);
    }
  };

  render() {
    return (
      <TouchableWithoutFeedback onPress={this.props.onDismiss}>
        <View style={styles.container}>
          <View style={styles.optionsContainer}>
            <Text style={styles.headerTitle}>Select document types</Text>
            {docTypes.map(d => (
              <DocumentType
                key={d.id}
                onPress={() => this._onItemPress(d)}
                text={d.title}
                isSelected={this.state.selections.find(s => s.id === d.id) !== undefined}
              />
            ))}
            <TouchableOpacity
              style={styles.selectButton}
              onPress={this._onSelect}
            >
              <Text style={styles.selectButtonTitle}>Select</Text>
            </TouchableOpacity>
          </View>
        </View>
      </TouchableWithoutFeedback>
    )
  }
}

export default DocumentTypesSelector;
