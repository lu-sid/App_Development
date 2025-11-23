// fire.js
import ReactNativeAsyncStorage from "@react-native-async-storage/async-storage";
import { initializeApp } from "firebase/app";
import {
  getReactNativePersistence,
  initializeAuth,
} from "firebase/auth";
import { getFirestore } from "firebase/firestore";

export const firebaseConfig = {
  apiKey: "AIzaSyAezNdExsMf8OYWL108FjgJ2lC2vglWrRU",
  authDomain: "lusid-55.firebaseapp.com",
  projectId: "lusid-55",
  storageBucket: "lusid-55.appspot.com",
  messagingSenderId: "436717388929",
  appId: "1:436717388929:android:d9842a484f5a5bfcd37980",
};


// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Auth with persistence
const auth = initializeAuth(app, {
  persistence: getReactNativePersistence(ReactNativeAsyncStorage),
});

// Firestore
const db = getFirestore(app);

export { auth, db };

