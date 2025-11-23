import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';
import MyButton from '../src/MyButton';

test("button triggers onPress", () => {
  const mockFn = jest.fn();
  const { getByText } = render(<MyButton title="Click me" onPress={mockFn} />);
  fireEvent.press(getByText("Click me"));
  expect(mockFn).toHaveBeenCalled();
});
