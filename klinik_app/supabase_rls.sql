-- 🛡️ Supabase Row Level Security (RLS) Policies untuk Klinik App
-- Pastikan untuk menjalankan script ini di Supabase SQL Editor.

-- Enable RLS pada semua tabel public
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medical_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- 1. Table: users
-- Hanya user yang bersangkutan dan admin yang bisa melihat data profil.
CREATE POLICY "User can view own profile" 
ON public.users FOR SELECT 
USING (auth.uid() = id OR (auth.jwt() ->> 'role') = 'admin');

CREATE POLICY "User can update own profile" 
ON public.users FOR UPDATE 
USING (auth.uid() = id OR (auth.jwt() ->> 'role') = 'admin');


-- 2. Table: medical_records
-- Pasien bisa melihat rekam medisnya sendiri. Dokter dan Admin bisa melihat semua.
CREATE POLICY "Patients can view their own medical records"
ON public.medical_records FOR SELECT
USING (patient_id = auth.uid() OR (auth.jwt() ->> 'role') IN ('dokter', 'admin'));

-- Hanya Dokter dan Admin yang bisa memasukkan/update rekam medis.
CREATE POLICY "Only doctors and admins can write medical records"
ON public.medical_records FOR INSERT
WITH CHECK ((auth.jwt() ->> 'role') IN ('dokter', 'admin'));

CREATE POLICY "Only doctors and admins can update medical records"
ON public.medical_records FOR UPDATE
USING ((auth.jwt() ->> 'role') IN ('dokter', 'admin'));


-- 3. Table: transactions (Payments/QRIS)
-- Pasien bisa melihat transaksinya sendiri. Admin bisa melihat semuanya.
CREATE POLICY "Patients can view their own transactions"
ON public.transactions FOR SELECT
USING (patient_id = auth.uid() OR (auth.jwt() ->> 'role') = 'admin');

-- Hanya Admin yang bisa mengelola transaksi.
CREATE POLICY "Only admins can insert transactions"
ON public.transactions FOR INSERT
WITH CHECK ((auth.jwt() ->> 'role') = 'admin');

CREATE POLICY "Only admins can update transactions"
ON public.transactions FOR UPDATE
USING ((auth.jwt() ->> 'role') = 'admin');
