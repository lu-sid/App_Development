import {
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDocs,
  updateDoc,
} from "firebase/firestore";
import { useEffect, useState } from "react";
import {
  Alert,
  Button,
  FlatList,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from "react-native";
import { db } from "../../firebaseConfig";
 // ✅ make sure this path is correct

export default function FormScreen() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [age, setAge] = useState("");
  const [users, setUsers] = useState([]);
  const [editingId, setEditingId] = useState(null); // to check if we are editing

  // 🔹 Fetch users on app start
  useEffect(() => {
    fetchUsers();
  }, []);

  // 🔹 CREATE or UPDATE user
  const handleSubmit = async () => {
    if (!name || !email || !age) {
      Alert.alert("Error", "Please fill all fields");
      return;
    }

    try {
      if (editingId) {
        // 🔹 Update existing user
        const userRef = doc(db, "users", editingId);
        await updateDoc(userRef, {
          name,
          email,
          age: parseInt(age),
        });
        Alert.alert("Success", "User Updated!");
        setEditingId(null);
      } else {
        // 🔹 Add new user
        await addDoc(collection(db, "users"), {
          name,
          email,
          age: parseInt(age),
        });
        Alert.alert("Success", "User Added!");
      }

      setName("");
      setEmail("");
      setAge("");
      fetchUsers(); // Refresh after add/update
    } catch (e) {
      console.error("Error saving user: ", e);
    }
  };

  // 🔹 READ users
  const fetchUsers = async () => {
    try {
      const querySnapshot = await getDocs(collection(db, "users"));
      const userList = querySnapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));
      setUsers(userList);
    } catch (e) {
      console.error("Error fetching users: ", e);
    }
  };

  // 🔹 DELETE user
  const handleDelete = async (id) => {
    try {
      await deleteDoc(doc(db, "users", id));
      Alert.alert("Deleted", "User removed!");
      fetchUsers(); // Refresh after delete
    } catch (e) {
      console.error("Error deleting user: ", e);
    }
  };

  // 🔹 When user clicks Edit
  const handleEdit = (user) => {
    setName(user.name);
    setEmail(user.email);
    setAge(String(user.age));
    setEditingId(user.id);
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>User Registration</Text>

      <TextInput
        style={styles.input}
        placeholder="Enter Name"
        value={name}
        onChangeText={setName}
      />
      <TextInput
        style={styles.input}
        placeholder="Enter Email"
        value={email}
        keyboardType="email-address"
        onChangeText={setEmail}
      />
      <TextInput
        style={styles.input}
        placeholder="Enter Age"
        value={age}
        keyboardType="numeric"
        onChangeText={setAge}
      />

      <Button
        title={editingId ? "Update User" : "Add User"}
        onPress={handleSubmit}
      />

      <Text style={styles.subtitle}>User List</Text>
      <FlatList
        data={users}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <View style={styles.userItem}>
            <View style={{ flex: 1 }}>
              <Text style={styles.userText}>{item.name}</Text>
              <Text>{item.email}</Text>
              <Text>Age: {item.age}</Text>
            </View>

            <TouchableOpacity
              style={styles.editBtn}
              onPress={() => handleEdit(item)}
            >
              <Text style={{ color: "white" }}>Edit</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={styles.deleteBtn}
              onPress={() => handleDelete(item.id)}
            >
              <Text style={{ color: "white" }}>Delete</Text>
            </TouchableOpacity>
          </View>
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    backgroundColor: "#f9f9f9",
  },
  title: {
    fontSize: 24,
    fontWeight: "bold",
    textAlign: "center",
    marginBottom: 20,
  },
  subtitle: {
    fontSize: 20,
    fontWeight: "600",
    marginVertical: 15,
  },
  input: {
    borderWidth: 1,
    borderColor: "#aaa",
    padding: 10,
    borderRadius: 10,
    marginBottom: 10,
  },
  userItem: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#fff",
    borderRadius: 10,
    padding: 10,
    marginVertical: 5,
    shadowColor: "#000",
    shadowOpacity: 0.1,
    shadowRadius: 5,
    elevation: 3,
  },
  userText: {
    fontWeight: "bold",
  },
  editBtn: {
    backgroundColor: "#007bff",
    padding: 8,
    borderRadius: 8,
    marginHorizontal: 5,
  },
  deleteBtn: {
    backgroundColor: "#dc3545",
    padding: 8,
    borderRadius: 8,
  },
});