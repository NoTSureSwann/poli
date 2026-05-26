-- Script untuk membuat tabel profiles dan mengatur Role-Based Access Control (RBAC)
-- Silakan jalankan script ini di menu "SQL Editor" pada Supabase Dashboard Anda.

-- 1. Buat tabel profiles
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  role TEXT NOT NULL CHECK (role IN ('admin', 'pasien', 'dokter')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 2. Aktifkan Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 3. Policy: User bisa membaca datanya sendiri
CREATE POLICY "User can read own profile" 
ON public.profiles 
FOR SELECT 
USING (auth.uid() = id);

-- 4. Policy: Admin bisa membaca semua profile
CREATE POLICY "Admin can read all profiles" 
ON public.profiles 
FOR SELECT 
USING (
  (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
);

-- 5. Trigger otomatis insert data default ke profiles (pasien) tiap ada user baru
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, role)
  VALUES (new.id, 'pasien');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Pasang trigger ke tabel auth.users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
