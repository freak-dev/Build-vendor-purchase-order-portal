import {test,expect} from '@playwright/test';

const user=process.env.E2E_USER||'admin';
const pass=process.env.E2E_PASSWORD||'change-me';
const unique=()=>`${Date.now()}-${Math.random().toString(16).slice(2,8)}`;

test.beforeEach(async({page})=>{
  await page.goto('/');
  await page.getByLabel('Username').fill(user);
  await page.getByLabel('Password').fill(pass);
  await page.getByRole('button',{name:'Sign in'}).click();
  await expect(page.getByRole('heading',{name:'Good morning'})).toBeVisible();
});

test('user login shows live dashboard',async({page})=>{
  await expect(page.getByText('Live data')).toBeVisible();
});

test('vendor creation',async({page})=>{
  const email=`e2e-${unique()}@example.test`;
  await page.getByRole('button',{name:'Vendors'}).click();
  await page.getByRole('button',{name:'Add vendor'}).click();
  await page.getByLabel('Company name').fill(`E2E Supplier ${unique()}`);
  await page.getByLabel('Email').fill(email);
  await page.locator('.modal').getByRole('button',{name:'Add vendor'}).click();
  await expect(page.getByRole('cell',{name:email})).toBeVisible();
});

test('product creation',async({page})=>{
  const id=unique(),sku=`E2E-${id}`;
  await page.getByRole('button',{name:'Products'}).click();
  await page.getByRole('button',{name:'Add product'}).click();
  await page.getByLabel('SKU').fill(sku);
  await page.getByLabel('Product name').fill(`E2E Product ${id}`);
  await page.getByLabel('Category').fill('Testing');
  await page.getByLabel('Unit price (INR)').fill('125');
  await page.getByLabel('Opening stock').fill('10');
  await page.locator('.modal').getByRole('button',{name:'Add product'}).click();
  await expect(page.getByRole('cell',{name:sku})).toBeVisible();
});

async function createOrder(page){
  await page.getByRole('button',{name:'Purchase orders'}).click();
  await page.getByRole('button',{name:'New order'}).click();
  const selects=page.locator('.modal select');
  await expect(selects).toHaveCount(2);
  await selects.nth(0).selectOption({index:1});
  await selects.nth(1).selectOption({index:1});
  await page.locator('.modal').getByRole('button',{name:'Create order'}).click();
  await expect(page.getByText('Purchase order created')).toBeVisible({timeout:10000});
}

test('purchase order creation',async({page})=>{
  await createOrder(page);
  await expect(page.locator('tbody tr').first()).toContainText('Pending');
});

test('purchase order advances to approved',async({page})=>{
  await createOrder(page);
  const action=page.locator('.workflow button').filter({hasText:'Approve'}).first();
  await expect(action).toBeVisible();
  await action.click();
  await expect(page.getByText('Order approved')).toBeVisible();
});
