import React, { useState } from "react";
import { Alert, ScrollView, View } from "react-native";
import { Button, Checkbox, RadioButton, Text, TextInput } from "react-native-paper";
import { Picker } from "@react-native-picker/picker";
import Slider from "@react-native-community/slider";
import DateTimePicker from "@react-native-community/datetimepicker";
import { addDoc, collection } from "firebase/firestore";
import { db, auth } from "../../fire";

export default function FormScreen() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [gender, setGender] = useState("female");
  const [course, setCourse] = useState("BE");
  const [agree, setAgree] = useState(false);
  const [age, setAge] = useState(18);
  const [date, setDate] = useState(new Date());
  const [showDate, setShowDate] = useState(false);

  const onSubmit = async () => {
    if (!name || !email || !agree) {
      Alert.alert("Error", "Please fill all required fields");
      return;
    }

    try {
      await addDoc(collection(db, "students"), {
        name,
        email,
        gender,
        course,
        age,
        dob: date.toDateString(),
        agreed: agree,
        createdAt: new Date(),
      });

      Alert.alert(
        "Registration Successful 🎉",
        `Name: ${name}\nEmail: ${email}\nGender: ${gender}\nCourse: ${course}\nAge: ${age}\nDOB: ${date.toDateString()}`
      );

      setName("");
      setEmail("");
      setGender("female");
      setCourse("BE");
      setAgree(false);
      setAge(18);
      setDate(new Date());
    } catch (error) {
      console.error("Error adding document: ", error);
      Alert.alert("Error", "Something went wrong. Please try again.");
    }
  };

  return (
    <ScrollView contentContainerStyle={{ padding: 20, backgroundColor: "#fff", flexGrow: 1 }}>
      <Text style={{ fontSize: 24, fontWeight: "bold", color: "red", textAlign: "center", marginBottom: 20 }}>
        Student Registration Form
      </Text>

      <TextInput
        label="Full Name"
        value={name}
        onChangeText={setName}
        mode="outlined"
        style={{ marginBottom: 15 }}
      />

      <TextInput
        label="Email"
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
        mode="outlined"
        style={{ marginBottom: 15 }}
      />

      <Text style={{ marginTop: 10, fontWeight: "600" }}>Gender</Text>
      <RadioButton.Group onValueChange={setGender} value={gender}>
        <View style={{ flexDirection: "row", alignItems: "center" }}>
          <RadioButton value="female" />
          <Text>Female</Text>
          <RadioButton value="male" />
          <Text>Male</Text>
        </View>
      </RadioButton.Group>

      <Text style={{ marginTop: 10, fontWeight: "600" }}>Select Course</Text>
      <View style={{ borderWidth: 1, borderColor: "#aaa", borderRadius: 5, marginVertical: 10 }}>
        <Picker selectedValue={course} onValueChange={setCourse}>
          <Picker.Item label="BCA" value="BCA" />
          <Picker.Item label="BE" value="BE" />
          <Picker.Item label="BCom" value="BCom" />
          <Picker.Item label="BA" value="BA" />
        </Picker>
      </View>

      <Text style={{ fontWeight: "600", marginTop: 10 }}>Age: {age}</Text>
      <Slider
        style={{ width: "100%", height: 40 }}
        minimumValue={16}
        maximumValue={40}
        step={1}
        minimumTrackTintColor="red"
        maximumTrackTintColor="#ccc"
        value={age}
        onValueChange={setAge}
      />

      <Button mode="outlined" onPress={() => setShowDate(true)} style={{ marginTop: 10 }}>
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

      <View style={{ flexDirection: "row", alignItems: "center", marginTop: 15 }}>
        <Checkbox status={agree ? "checked" : "unchecked"} onPress={() => setAgree(!agree)} color="red" />
        <Text>I agree to the terms and conditions</Text>
      </View>

      <Button mode="contained" onPress={onSubmit} style={{ marginTop: 20, backgroundColor: "blue" }}>
        Submit
      </Button>
    </ScrollView>
  );
}
