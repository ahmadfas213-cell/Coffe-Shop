create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text,
  avatar_url text,
  role text not null default 'staff' check (role in ('owner','admin','staff')),
  created_at timestamptz not null default now()
);

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references public.categories(id) on delete set null,
  name text not null,
  category text not null default 'Other',
  description text,
  price numeric(12,2) not null check (price >= 0),
  image_url text,
  is_available boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  created_by uuid references auth.users(id) on delete set null,
  customer_name text,
  status text not null default 'pending' check (status in ('pending','processing','completed','cancelled')),
  subtotal numeric(12,2) not null default 0,
  total numeric(12,2) not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  product_name text not null,
  quantity integer not null check (quantity > 0),
  unit_price numeric(12,2) not null check (unit_price >= 0),
  line_total numeric(12,2) not null check (line_total >= 0)
);

create table if not exists public.inventory (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  quantity numeric(12,2) not null default 0 check (quantity >= 0),
  unit text not null default 'pcs',
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.inventory enable row level security;

-- Authenticated staff can read workspace data.
create policy "Authenticated users can read profiles"
on public.profiles for select to authenticated using (true);

create policy "Users can update own profile"
on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

create policy "Authenticated users can read categories"
on public.categories for select to authenticated using (true);
create policy "Authenticated users can manage categories"
on public.categories for all to authenticated using (true) with check (true);

create policy "Authenticated users can read products"
on public.products for select to authenticated using (true);
create policy "Authenticated users can manage products"
on public.products for all to authenticated using (true) with check (true);

create policy "Authenticated users can read orders"
on public.orders for select to authenticated using (true);
create policy "Authenticated users can create orders"
on public.orders for insert to authenticated with check (true);
create policy "Authenticated users can update orders"
on public.orders for update to authenticated using (true) with check (true);

create policy "Authenticated users can read order items"
on public.order_items for select to authenticated using (true);
create policy "Authenticated users can manage order items"
on public.order_items for all to authenticated using (true) with check (true);

create policy "Authenticated users can read inventory"
on public.inventory for select to authenticated using (true);
create policy "Authenticated users can manage inventory"
on public.inventory for all to authenticated using (true) with check (true);

-- Automatically create a profile after a new Google/email sign-in.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name'),
    new.email,
    coalesce(new.raw_user_meta_data->>'avatar_url', new.raw_user_meta_data->>'picture')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Product categories are stored as labels for this lightweight first release.
-- Seed starter catalog only when the products table is empty.
insert into public.products (name, category, description, price, image_url, is_available)
select seed.name, seed.category, seed.description, seed.price, seed.image_url, true
from (values
 ('Brown Sugar Latte','Coffee','Espresso, milk, brown sugar',32000::numeric,'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=700&q=85'),
 ('Iced Americano','Coffee','Double espresso, cold water',24000::numeric,'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=700&q=85'),
 ('Cappuccino','Coffee','Espresso with silky milk foam',28000::numeric,'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=700&q=85'),
 ('Matcha Latte','Non Coffee','Japanese matcha, fresh milk',30000::numeric,'https://images.unsplash.com/photo-1515823064-d6e0c04616a7?w=700&q=85'),
 ('Cafe Mocha','Coffee','Espresso, chocolate, milk',33000::numeric,'https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?w=700&q=85'),
 ('Butter Croissant','Bakery','Flaky, buttery, freshly baked',22000::numeric,'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=700&q=85')
) as seed(name,category,description,price,image_url)
where not exists (select 1 from public.products);
