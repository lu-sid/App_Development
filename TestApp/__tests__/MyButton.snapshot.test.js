import React from 'react';
import renderer from 'react-test-renderer';
import MyButton from '../src/MyButton';

test('MyButton matches snapshot', () => {
  const tree = renderer
    .create(<MyButton title="Snapshot Test" onPress={() => {}} />)
    .toJSON();
  expect(tree).toMatchSnapshot();
});
