// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyBd8_juAGnl2vbuEMn-BHXWEpXdMN2GDxc",
  authDomain: "lusid-55.firebaseapp.com",
  projectId: "lusid-55",
  storageBucket: "lusid-55.firebasestorage.app",
  messagingSenderId: "436717388929",
  appId: "1:436717388929:web:8362ebf2929ce7a4d37980"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// ✅ Get Firestore instance
const db = getFirestore(app);

export { db };