// app/(tabs)/dashboard.js
import React, { useEffect, useState } from "react";
import { View, FlatList, Alert, TextInput } from "react-native";
import { Text, Button } from "react-native-paper";
import { db } from "../../fire.js";
import {
  collection,
  getDocs,
  deleteDoc,
  updateDoc,
  doc
} from "firebase/firestore";
import { useNavigation } from "@react-navigation/native";

export default function Dashboard() {
  const navigation = useNavigation();
  const [users, setUsers] = useState([]);
  const [editingId, setEditingId] = useState(null);
  const [editName, setEditName] = useState("");
  const [editCourse, setEditCourse] = useState("");

  const fetchUsers = async () => {
    try {
      const snapshot = await getDocs(collection(db, "students"));
      const list = snapshot.docs.map((d) => ({ id: d.id, ...d.data() }));
      setUsers(list);
    } catch (error) {
      Alert.alert("Error fetching data", error.message);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const deleteUser = async (id) => {
    try {
      await deleteDoc(doc(db, "students", id));
      Alert.alert("Deleted", "User removed successfully");
      fetchUsers();
    } catch (error) {
      Alert.alert("Error", error.message);
    }
  };

  const updateUser = async () => {
    try {
      await updateDoc(doc(db, "students", editingId), {
        name: editName,
        course: editCourse,
      });
      Alert.alert("Updated", "User updated successfully");
      setEditingId(null);
      fetchUsers();
    } catch (error) {
      Alert.alert("Error", error.message);
    }
  };

  return (
    <View style={{ flex: 1, padding: 20 }}>
      <Text
        style={{
          fontSize: 26,
          fontWeight: "bold",
          textAlign: "center",
          marginBottom: 20,
        }}
      >
        Students Dashboard (CRUD)
      </Text>

      {/* ➕ Add new student */}
      <Button
        mode="contained"
        style={{ backgroundColor: "green", marginBottom: 15 }}
        onPress={() => navigation.navigate("Form")}
      >
        ➕ Add New Student
      </Button>

      {/* Editing card */}
      {editingId && (
        <View
          style={{
            backgroundColor: "#fff",
            padding: 15,
            borderRadius: 8,
            marginBottom: 15,
          }}
        >
          <Text style={{ fontWeight: "bold", fontSize: 18 }}>Update User</Text>
          <TextInput
            placeholder="Edit Name"
            value={editName}
            onChangeText={setEditName}
            style={{
              borderWidth: 1,
              borderColor: "#aaa",
              borderRadius: 8,
              marginVertical: 10,
              padding: 10,
            }}
          />
          <TextInput
            placeholder="Edit Course"
            value={editCourse}
            onChangeText={setEditCourse}
            style={{
              borderWidth: 1,
              borderColor: "#aaa",
              borderRadius: 8,
              padding: 10,
            }}
          />
          <Button mode="contained" style={{ marginTop: 10 }} onPress={updateUser}>
            Save Changes
          </Button>
        </View>
      )}

      {/* Students list */}
      <FlatList
        data={users}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <View
            style={{
              backgroundColor: "#f2f2f2",
              padding: 15,
              borderRadius: 10,
              marginBottom: 10,
            }}
          >
            <Text style={{ fontSize: 18, fontWeight: "bold" }}>{item.name}</Text>
            <Text>Email: {item.email}</Text>
            <Text>Course: {item.course}</Text>
            <Text>Age: {item.age}</Text>

            <Button
              mode="contained"
              style={{ backgroundColor: "blue", marginTop: 10 }}
              onPress={() => {
                setEditingId(item.id);
                setEditName(item.name);
                setEditCourse(item.course);
              }}
            >
              Edit
            </Button>

            <Button
              mode="contained"
              style={{ backgroundColor: "red", marginTop: 10 }}
              onPress={() => deleteUser(item.id)}
            >
              Delete
            </Button>
          </View>
        )}
      />
    </View>
  );
}
