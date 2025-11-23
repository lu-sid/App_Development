import axios from "axios";
import React, { useEffect, useState } from "react";
import {
  ActivityIndicator,
  StyleSheet,
  Text,
  TextInput,
  View,
  FlatList,
} from "react-native";
import { Picker } from "@react-native-picker/picker";

export default function App() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [base, setBase] = useState("USD"); // Base currency
  const [search, setSearch] = useState(""); // Text search filter

  const fetchExchangeRate = () => {
    setLoading(true);

    axios
      .get(`https://open.er-api.com/v6/latest/${base}`)
      .then((response) => {
        setData(response.data.rates);
        setLoading(false);
      })
      .catch((error) => {
        console.error("Error fetching data:", error);
        setLoading(false);
        setData(null);
      });
  };

  useEffect(() => {
    fetchExchangeRate();
  }, [base]);

  if (loading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" color="#00eaff" />
        <Text style={styles.text}>Fetching currency rates...</Text>
      </View>
    );
  }

  const currencyKeys = Object.keys(data || {});
  const filteredKeys = currencyKeys.filter((item) =>
    item.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <View style={styles.container}>
      <Text style={styles.title}>💱 Currency Exchange Dashboard</Text>

      {/* Dropdown for base currency */}
      <Picker
        selectedValue={base}
        onValueChange={(val) => setBase(val)}
        style={styles.picker}
        dropdownIconColor="#00eaff"
      >
        {["USD", "INR", "EUR", "GBP", "JPY", "AED", "AUD", "CAD"].map((c) => (
          <Picker.Item label={c} value={c} key={c} />
        ))}
      </Picker>

      {/* Search input for target currencies */}
      <TextInput
        style={styles.input}
        placeholder="Search target currency (e.g. INR, GBP)"
        placeholderTextColor="#7d8ca3"
        value={search}
        onChangeText={setSearch}
      />

      {/* Exchange rate list */}
      <FlatList
        data={filteredKeys}
        keyExtractor={(item) => item}
        renderItem={({ item }) => (
          <View style={styles.card}>
            <Text style={styles.heading}>
              1 {base} → {item}
            </Text>
            <Text style={styles.textRate}>{data[item].toFixed(3)}</Text>
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
    marginTop: 35,
    backgroundColor: "#f1f5fb",
  },
  center: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#f1f5fb",
  },
  title: {
    fontSize: 28,
    fontWeight: "bold",
    marginBottom: 15,
    textAlign: "center",
    color: "#005bea",
  },
  picker: {
    backgroundColor: "#fff",
    borderRadius: 10,
    elevation: 4,
    marginBottom: 10,
  },
  input: {
    borderWidth: 1,
    borderColor: "#b0c4de",
    borderRadius: 10,
    padding: 12,
    marginBottom: 12,
    fontSize: 16,
    backgroundColor: "#fff",
    color: "#000",
  },
  card: {
    backgroundColor: "#ffffff",
    padding: 16,
    borderRadius: 14,
    marginBottom: 12,
    borderLeftWidth: 6,
    borderLeftColor: "#00b4d8",
    elevation: 4,
  },
  heading: {
    fontSize: 18,
    fontWeight: "bold",
    color: "#023e8a",
    marginBottom: 6,
  },
  textRate: {
    fontSize: 20,
    fontWeight: "bold",
    color: "#0077b6",
  },
  text: {
    fontSize: 16,
    color: "#000",
  },
});
