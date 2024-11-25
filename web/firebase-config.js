// Import the functions you need from the SDKs you need
import { initializeApp } from "https://www.gstatic.com/firebasejs/9.23.0/firebase-app.js";
import { getAuth } from "https://www.gstatic.com/firebasejs/9.23.0/firebase-auth.js";
import { getFirestore } from "https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore.js";

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyAWdy3w-CNr1721Gi9GmJbzJzGmlUod_Wk",
  authDomain: "test-1f4db.firebaseapp.com",
  projectId: "test-1f4db",
  storageBucket: "test-1f4db.appspot.com",
  messagingSenderId: "1040716817417",
  appId: "1:1040716817417:web:e33bcca17c6383dfa5c4d8"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const firestore = getFirestore(app);

window.firebase = {
  app,
  auth,
  firestore
};
