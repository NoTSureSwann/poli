-- 🛡️ Supabase Row Level Security (RLS) Policies untuk Klinik App
-- Blok semua anonymous request secara default dengan RLS

-- Enable RLS
ALTER TABLE public.poli ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.antrian ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dokter ENABLE ROW LEVEL SECURITY;

-- 1. Table: poli
-- Tabel poli: semua user authenticated bisa SELECT, hanya admin bisa INSERT/UPDATE/DELETE
CREATE POLICY "Semua user authenticated bisa SELECT poli"
ON public.poli FOR SELECT
USING (auth.role() = 'authenticated');

CREATE POLICY "Hanya admin bisa INSERT poli"
ON public.poli FOR INSERT
WITH CHECK ((auth.jwt() ->> 'role') = 'admin');

CREATE POLICY "Hanya admin bisa UPDATE poli"
ON public.poli FOR UPDATE
USING ((auth.jwt() ->> 'role') = 'admin');

CREATE POLICY "Hanya admin bisa DELETE poli"
ON public.poli FOR DELETE
USING ((auth.jwt() ->> 'role') = 'admin');


-- 2. Table: antrian
-- Tabel antrian: pasien hanya bisa SELECT/INSERT data miliknya sendiri
-- dokter bisa SELECT semua antrian, admin bisa full access
CREATE POLICY "Pasien bisa SELECT antrian sendiri, dokter/admin semua"
ON public.antrian FOR SELECT
USING (pasien_id = auth.uid() OR (auth.jwt() ->> 'role') IN ('dokter', 'admin'));

CREATE POLICY "Pasien bisa INSERT antrian sendiri, admin bisa semua"
ON public.antrian FOR INSERT
WITH CHECK (pasien_id = auth.uid() OR (auth.jwt() ->> 'role') = 'admin');

CREATE POLICY "Hanya dokter dan admin yang bisa UPDATE antrian"
ON public.antrian FOR UPDATE
USING ((auth.jwt() ->> 'role') IN ('dokter', 'admin'));

CREATE POLICY "Hanya admin yang bisa DELETE antrian"
ON public.antrian FOR DELETE
USING ((auth.jwt() ->> 'role') = 'admin');


-- 3. Table: dokter
-- Asumsi dokter mirip dengan poli, bisa dilihat semua, tapi hanya diubah admin
CREATE POLICY "Semua user authenticated bisa SELECT dokter"
ON public.dokter FOR SELECT
USING (auth.role() = 'authenticated');

CREATE POLICY "Hanya admin bisa memodifikasi dokter"
ON public.dokter FOR ALL
USING ((auth.jwt() ->> 'role') = 'admin');
