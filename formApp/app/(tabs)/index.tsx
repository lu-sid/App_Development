import DateTimePicker from "@react-native-community/datetimepicker";
import Slider from "@react-native-community/slider";
import { Picker } from "@react-native-picker/picker";
import * as React from "react";
import { Alert, ScrollView, View } from "react-native";
import {
  Button,
  Checkbox,
  RadioButton,
  Text,
  TextInput
} from "react-native-paper";

export default function App() {
  const [name, setName] = React.useState("");
  const [email, setEmail] = React.useState("");
  const [gender, setGender] = React.useState("female");
  const [course, setCourse] = React.useState("BE");
  const [agree, setAgree] = React.useState(false);
  const [age, setAge] = React.useState(18);
  const [date, setDate] = React.useState(new Date());
  const [showDate, setShowDate] = React.useState(false);

  const onSubmit = () => {
    if (!name || !email || !agree) {
      Alert.alert("Error", "Please fill all required fields");
      return;
    }

    Alert.alert(
      "Registration Successful",
      `Name: ${name}\nEmail: ${email}\nGender: ${gender}\nCourse: ${course}\nAge: ${age}\nDate: ${date.toDateString()}`
    );
  };

  return (
    <ScrollView
      contentContainerStyle={{
        padding: 20,
        backgroundColor: "#fff",
        flexGrow: 1,
      }}
    >
      <Text
        style={{
          fontSize: 24,
          fontWeight: "bold",
          color: "red",
          textAlign: "center",
          marginBottom: 20,
        }}
      >
        Student Registration Form
      </Text>

      {/* Name */}
      <TextInput
        label="Full Name"
        value={name}
        onChangeText={setName}
        mode="outlined"
        style={{ marginBottom: 15 }}
      />

      {/* Email */}
      <TextInput
        label="Email"
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
        mode="outlined"
        style={{ marginBottom: 15 }}
      />

      {/* Gender - Radio Buttons */}
      <Text style={{ marginTop: 10, fontWeight: "600" }}>Gender</Text>
      <RadioButton.Group
        onValueChange={(newValue) => setGender(newValue)}
        value={gender}
      >
        <View style={{ flexDirection: "row", alignItems: "center" }}>
          <RadioButton value="female" />
          <Text>Female</Text>
          <RadioButton value="male" />
          <Text>Male</Text>
        </View>
      </RadioButton.Group>

      {/* Dropdown */}
      <Text style={{ marginTop: 10, fontWeight: "600" }}>Select Course</Text>
      <View
        style={{
          borderWidth: 1,
          borderColor: "#aaa",
          borderRadius: 5,
          marginVertical: 10,
        }}
      >
        <Picker selectedValue={course} onValueChange={(itemValue) => setCourse(itemValue)}>
          <Picker.Item label="BCA" value="BCA" />
          <Picker.Item label="BE" value="BE" />
          <Picker.Item label="BCom" value="BCom" />
          <Picker.Item label="BA" value="BA" />
        </Picker>
      </View>

      {/* Age Slider */}
      <Text style={{ fontWeight: "600", marginTop: 10 }}>Age: {age}</Text>
      <Slider
        style={{ width: "100%", height: 40 }}
        minimumValue={16}
        maximumValue={40}
        step={1}
        minimumTrackTintColor="red"
        maximumTrackTintColor="#ccc"
        value={age}
        onValueChange={(value) => setAge(value)}
      />

      {/* Date Picker */}
      <Button
        mode="outlined"
        onPress={() => setShowDate(true)}
        style={{ marginTop: 10 }}
      >
        Select Date of Birth
      </Button>
      {showDate && (
        <DateTimePicker
          value={date}
          mode="date"
          display="default"
          onChange={(event, selectedDate) => {
            setShowDate(false);
            if (selectedDate) setDate(selectedDate);
          }}
        />
      )}

      {/* Checkbox */}
      <View style={{ flexDirection: "row", alignItems: "center", marginTop: 15 }}>
        <Checkbox
          status={agree ? "checked" : "unchecked"}
          onPress={() => setAgree(!agree)}
          color="red"
        />
        <Text>I agree to the terms and conditions</Text>
      </View>

      {/* Submit Button */}
      <Button
        mode="contained"
        onPress={onSubmit}
        style={{
          marginTop: 20,
          backgroundColor: "blue",
          padding: 6,
          borderRadius: 10,
        }}
      >
        Submit
      </Button>
    </ScrollView>
  );
}
