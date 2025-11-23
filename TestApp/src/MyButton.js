import React from 'react';
import { View, Button } from 'react-native';

export default function MyButton({ title, onPress }) {
  return (
    <View>
      <Button title={title} onPress={onPress} />
    </View>
  );
}
