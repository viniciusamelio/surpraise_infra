import 'package:supabase/supabase.dart';

abstract class TestSettings {
  static String dbConnection = "mongodb://127.0.0.1:27017/surpraise";
}

const supabaseUrl = 'http://localhost:8000';
const supabaseKey =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB5aWt2c2R1ZXRmYWt0cm53d2N1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTY5ODQ0MTEsImV4cCI6MjAxMjU2MDQxMX0.AhBw4GTJjindZLDQMF49qmLeAWmAFpAU9hmv1DwrEHI";

Future<SupabaseClient> supabaseClient() async {
  final client = SupabaseClient(supabaseUrl, supabaseKey);
  await client.auth.signInWithPassword(
    password: "12345678",
    email: "fake@fake.com",
  );
  return client;
}
