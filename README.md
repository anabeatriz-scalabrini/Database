# Retail Store Database Management (Lojas Render)

This repository contains the complete relational database architecture, implementation, and data analysis scripts for a fictional clothing retail chain ("Lojas Render"). 

The project was developed as part of the **Database** course at **UNIFESP (Federal University of São Paulo)** in **2025**.

## Project Overview
The database is built to handle end-to-end retail processes. It features an advanced relational schema with strict integrity constraints, automated routines via database triggers, and a comprehensive suite of analytical queries designed for Business Intelligence (BI).

## Database Architecture
The schema is divided into four main operational domains, ensuring normalized data distribution:

| Domain | Core Tables | Description |
| :--- | :--- | :--- |
| **Sales & Customers** | `Cliente`, `Venda`, `Item_Venda`, `Desconto` | Tracks customer demographics, transactions, payment methods, and applied promotional discounts. |
| **Inventory & Products** | `Produto`, `Estoque`, `Colecao` | Manages clothing items, active/inactive collections, and stock levels across different branches. |
| **Supply Chain** | `Fornecedor`, `Compra`, `Item_Compra`, `Tipo_Insumo` | Controls purchasing from suppliers, raw material categories, and procurement costs. |
| **HR & Operations** | `Filial`, `Funcionario`, `Cargo`, `Meta_Venda`, `Comissionamento` | Manages store branches, employee hierarchy, sales targets, and performance-based commission payouts. |

## Automated Business Rules (Triggers)
To ensure data integrity and prevent manual errors, the system relies on automated triggers for inventory control:
* **`trg_entrada_estoque`**: Automatically intercepts new purchase records (`Item_Compra`) and dynamically increments the product stock levels for the receiving branch.
* **`trg_saida_estoque`**: Automatically triggers upon a registered sale (`Item_Venda`), deducting the exact quantity of products from the specific branch's inventory.

## Data Analytics & Business Intelligence
The repository includes 20 advanced SQL queries utilizing complex joins, aggregations, and filtering to extract strategic business insights. Key analyses include:

* **Profitability Analysis:** Calculating the exact profit margin per product by comparing total procurement costs against total sales revenue (Top 3 most profitable products).
* **Break-Even Point:** Determining the minimum sales volume required for each product to offset its supply costs.
* **Performance Tracking:** Identifying top-selling employees, branch revenue averages, and commission target achievements (>100% goal hit rate).
* **Operational Auditing:** Finding isolated records, such as registered discounts never applied, empty collections, and suppliers with zero transaction history.

## Technologies Used
* SQL (Data Definition, Manipulation, and Query Languages - DDL, DML, DQL)
* Relational Database Modeling (Primary/Foreign Keys, Constraints)
* Stored Programs (Triggers)
