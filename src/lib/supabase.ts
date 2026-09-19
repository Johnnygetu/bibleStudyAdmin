import { createClient } from '@supabase/supabase-js';

export const supabaseUrl =
  import.meta.env.VITE_SUPABASE_URL ||
  'https://nnzoqprlvutubwomkjdc.supabase.co';
export const supabaseAnonKey =
  import.meta.env.VITE_SUPABASE_ANON_KEY ||
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5uem9xcHJsdnV0dWJ3b21ramRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk2OTU1MDcsImV4cCI6MjEwNTI3MTUwN30.ZPZ1MZ1C6zOJiaP3UVIdlLrhkI_CgVKK47mrwYVr5Zs';

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: { persistSession: false },
});

