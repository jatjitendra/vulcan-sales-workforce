# Retail & Inventory Analytics — Vulcan data product

Reference layout: **practice-insights-v2** (`/home/jitenderkumar/Downloads/practice-insights-v2`)

Pacific: **pacific-051426** · Tenant: **ct-sandbox** · Product: **retail-inventory-jk**

## Layout

```
retail-inventory-jk/vulcan/
├── config.yaml
├── config.local.yaml
├── retail-inventory-deploy.yaml
├── external_models.yaml
├── models/
│   ├── staging/          # SEED models (stores, products, movements)
│   ├── marts/            # inventory_levels, store_performance_daily
│   ├── semantics/
│   └── dq/
└── seeds/
```

## Local validate

From repo root:

```bash
make local-check VULCAN_PRODUCT=retail-inventory-jk
```

## Deploy to Pacific

```bash
dataos-ctl resource apply -f vulcan-sales-workforce/retail-inventory-jk/vulcan/retail-inventory-deploy.yaml
```

Or:

```bash
make deploy-apply VULCAN_PRODUCT=retail-inventory-jk
```

## Models

| Model | Grain | Description |
|-------|-------|-------------|
| `staging.stores` | `store_id` | Store master |
| `staging.products` | `product_id` | Product catalog |
| `staging.stock_movements` | `movement_id` | Inventory movements |
| `marts.inventory_levels` | `(store_id, product_id)` | On-hand qty and value |
| `marts.store_performance_daily` | `(movement_date, store_id)` | Daily inbound/sale KPIs |
