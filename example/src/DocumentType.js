import React from 'react';
import { Text, StyleSheet, TouchableOpacity } from 'react-native';

const styles = StyleSheet.create({
  container: {
    width: '100%',
    height: 50,
    backgroundColor: 'white',
    justifyContent: 'center',
    borderBottomColor: '#ccc',
    borderBottomWidth: 1
  },
  textOption: {
    fontSize: 15,
    marginLeft: 16,
    fontWeight: '500'
  }
});

class DocumentTypesSelector extends React.Component {
  render() {
    const bgColor = this.props.isSelected ? 'green' : 'white';
    const textColor = this.props.isSelected ? 'white' : 'black';
    return (
      <TouchableOpacity style={[styles.container, { backgroundColor: bgColor }]} onPress={this.props.onPress}>
        <Text style={[styles.textOption, { color: textColor }]}>{this.props.text}</Text>
      </TouchableOpacity>
    )
  }
}

export default DocumentTypesSelector;
