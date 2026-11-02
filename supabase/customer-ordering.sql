-- BREWLY customer ordering: run once in Supabase SQL Editor.
-- Public visitors may read only available catalog items.
drop policy if exists "Public can read available products" on public.products;
create policy "Public can read available products" on public.products
for select to anon using (is_available = true);

-- Orders are created atomically on the server. Customer browser never supplies prices.
create or replace function public.place_customer_order(p_customer_name text, p_items jsonb)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_order_id uuid := gen_random_uuid();
  v_order_number text := 'BW-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8));
  v_total numeric(12,2) := 0;
  v_item jsonb;
  v_product public.products%rowtype;
  v_qty integer;
begin
  if length(trim(coalesce(p_customer_name, ''))) < 2 or length(trim(p_customer_name)) > 80 then
    raise exception 'Nama pemesan harus 2 sampai 80 karakter';
  end if;
  if jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 or jsonb_array_length(p_items) > 30 then
    raise exception 'Keranjang tidak valid';
  end if;
  for v_item in select value from jsonb_array_elements(p_items)
  loop
    v_qty := (v_item->>'quantity')::integer;
    if v_qty < 1 or v_qty > 30 then raise exception 'Jumlah item tidak valid'; end if;
    select * into v_product from public.products
      where id = (v_item->>'product_id')::uuid and is_available = true;
    if not found then raise exception 'Menu tidak tersedia'; end if;
    v_total := v_total + (v_product.price * v_qty);
  end loop;
  insert into public.orders(id, order_number, customer_name, status, subtotal, total)
  values(v_order_id, v_order_number, trim(p_customer_name), 'pending', v_total, v_total);
  for v_item in select value from jsonb_array_elements(p_items)
  loop
    v_qty := (v_item->>'quantity')::integer;
    select * into v_product from public.products
      where id = (v_item->>'product_id')::uuid and is_available = true;
    insert into public.order_items(order_id, product_id, product_name, quantity, unit_price, line_total)
    values(v_order_id, v_product.id, v_product.name, v_qty, v_product.price, v_product.price * v_qty);
  end loop;
  return v_order_number;
end;
$$;
revoke all on function public.place_customer_order(text, jsonb) from public;
grant execute on function public.place_customer_order(text, jsonb) to anon, authenticated;
