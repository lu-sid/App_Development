import * as SQLite from 'expo-sqlite';
import React, { useState, useEffect } from 'react';
import { View, Text, TextInput, Button, FlatList, TouchableOpacity, StyleSheet, KeyboardAvoidingView, Platform, ScrollView } from 'react-native';

let db;

async function initDB() {
  db = await SQLite.openDatabaseAsync('mydb.db');
  await db.execAsync(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      email TEXT
    );
  `);
}

export default function App() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [users, setUsers] = useState([]);
  const [editingUser, setEditingUser] = useState(null);

  useEffect(() => {
    (async () => {
      await initDB();
      await fetchUsers();
    })();
  }, []);

  const fetchUsers = async () => {
    const allRows = await db.getAllAsync('SELECT * FROM users');
    setUsers(allRows);
  };

  const addOrUpdateUser = async () => {
    if (!name || !email) return;
    if (editingUser) {
      await db.runAsync('UPDATE users SET name = ?, email = ? WHERE id = ?', [name, email, editingUser.id]);
      setEditingUser(null);
    } else {
      await db.runAsync('INSERT INTO users (name, email) VALUES (?, ?)', [name, email]);
    }
    setName('');
    setEmail('');
    await fetchUsers();
  };

  const deleteUser = async (id) => {
    await db.runAsync('DELETE FROM users WHERE id = ?', [id]);
    await fetchUsers();
  };

  const startEdit = (user) => {
    setName(user.name);
    setEmail(user.email);
    setEditingUser(user);
  };

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      style={styles.container}
    >
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <Text style={styles.title}>SQLite CRUD App</Text>

        <TextInput
          placeholder="Enter name"
          value={name}
          onChangeText={setName}
          style={styles.input}
        />
        <TextInput
          placeholder="Enter email"
          value={email}
          onChangeText={setEmail}
          style={styles.input}
        />

        <TouchableOpacity style={styles.addBtn} onPress={addOrUpdateUser}>
          <Text style={styles.btnText}>{editingUser ? 'Update User' : 'Add User'}</Text>
        </TouchableOpacity>

        <FlatList
          data={users}
          keyExtractor={(item) => item.id.toString()}
          contentContainerStyle={{ marginTop: 20 }}
          renderItem={({ item }) => (
            <View style={styles.card}>
              <View>
                <Text style={styles.userText}>{item.name}</Text>
                <Text style={styles.emailText}>{item.email}</Text>
              </View>
              <View style={styles.actions}>
                <TouchableOpacity style={styles.editBtn} onPress={() => startEdit(item)}>
                  <Text style={styles.btnSmallText}>Edit</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.deleteBtn} onPress={() => deleteUser(item.id)}>
                  <Text style={styles.btnSmallText}>Delete</Text>
                </TouchableOpacity>
              </View>
            </View>
          )}
        />
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F6F6F6',
    alignItems: 'center',
    justifyContent: 'center',
  },
  scrollContent: {
    width: '90%',
    paddingVertical: 30,
    alignItems: 'center',
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    marginBottom: 25,
    color: '#333',
    textAlign: 'center',
  },
  input: {
    width: '100%',
    borderColor: '#CCC',
    borderWidth: 1,
    borderRadius: 12,
    padding: 12,
    marginBottom: 12,
    backgroundColor: '#fff',
    fontSize: 16,
  },
  addBtn: {
    width: '100%',
    backgroundColor: '#007AFF',
    paddingVertical: 14,
    borderRadius: 12,
    alignItems: 'center',
    marginTop: 5,
    shadowColor: '#000',
    shadowOpacity: 0.1,
    shadowOffset: { width: 0, height: 2 },
  },
  btnText: {
    color: '#fff',
    fontSize: 17,
    fontWeight: '600',
  },
  card: {
    width: '100%',
    backgroundColor: '#fff',
    borderRadius: 14,
    padding: 15,
    marginBottom: 10,
    flexDirection: 'row',
    justifyContent: 'space-between',
    shadowColor: '#000',
    shadowOpacity: 0.08,
    shadowOffset: { width: 0, height: 2 },
    elevation: 2,
  },
  userText: {
    fontSize: 17,
    fontWeight: '600',
    color: '#333',
  },
  emailText: {
    fontSize: 14,
    color: '#666',
  },
  actions: {
    flexDirection: 'row',
    gap: 8,
  },
  editBtn: {
    backgroundColor: '#FFC107',
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 8,
  },
  deleteBtn: {
    backgroundColor: '#FF3B30',
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 8,
  },
  btnSmallText: {
    color: '#fff',
    fontSize: 13,
    fontWeight: '600',
  },
});
