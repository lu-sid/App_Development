// app/tabs/PhoneAuthScreen.js
import React, { useState } from "react";
import { View, Alert, TextInput as RNTextInput } from "react-native";
import { Button, Text } from "react-native-paper";
import { getAuth, signInWithPhoneNumber, RecaptchaVerifier } from "firebase/auth";
import { app } from "../../fire";

export default function PhoneAuthScreen() {
  const auth = getAuth(app);
  const [phone, setPhone] = useState("");
  const [otp, setOtp] = useState("");
  const [verificationId, setVerificationId] = useState(null);

  // 🔹 Send OTP
  const sendOTP = async () => {
    if (!phone) {
      Alert.alert("Error", "Enter a valid phone number");
      return;
    }
    try {
      const verifier = new RecaptchaVerifier(auth, "recaptcha-container", {
        size: "invisible",
      });

      const confirmation = await signInWithPhoneNumber(auth, phone, verifier);
      setVerificationId(confirmation.verificationId);
      Alert.alert("OTP Sent 📱", "Check your phone for the verification code");
    } catch (error) {
      console.error(error);
      Alert.alert("Error", error.message);
    }
  };

  // 🔹 Verify OTP
  const verifyOTP = async () => {
    if (!verificationId || !otp) {
      Alert.alert("Error", "Enter the OTP sent to your phone");
      return;
    }

    try {
      const credential = await auth.signInWithCredential(
        auth.PhoneAuthProvider.credential(verificationId, otp)
      );
      Alert.alert("Success ✅", "Phone verified and signed in!");
    } catch (error) {
      console.error(error);
      Alert.alert("Error", error.message);
    }
  };

  return (
    <View style={{ flex: 1, padding: 20, backgroundColor: "#fff", justifyContent: "center" }}>
      <Text style={{ fontSize: 24, fontWeight: "bold", textAlign: "center", marginBottom: 20 }}>
        Phone Number OTP Login
      </Text>

      <RNTextInput
        placeholder="+91XXXXXXXXXX"
        value={phone}
        onChangeText={setPhone}
        keyboardType="phone-pad"
        style={{
          borderWidth: 1,
          borderColor: "#aaa",
          borderRadius: 8,
          padding: 10,
          marginBottom: 15,
        }}
      />

      <Button mode="contained" onPress={sendOTP} style={{ marginBottom: 15, backgroundColor: "green" }}>
        Send OTP
      </Button>

      {verificationId && (
        <>
          <RNTextInput
            placeholder="Enter OTP"
            value={otp}
            onChangeText={setOtp}
            keyboardType="number-pad"
            style={{
              borderWidth: 1,
              borderColor: "#aaa",
              borderRadius: 8,
              padding: 10,
              marginBottom: 15,
            }}
          />
          <Button mode="contained" onPress={verifyOTP} style={{ backgroundColor: "blue" }}>
            Verify OTP
          </Button>
        </>
      )}

      <View id="recaptcha-container" />
    </View>
  );
}
