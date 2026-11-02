import {test,expect} from '@playwright/test';
test('sign-in screen renders access form',async({page})=>{await page.goto('/');await expect(page.getByRole('heading',{name:'Sign in to Procura'})).toBeVisible();await expect(page.getByLabel('Username')).toBeVisible();await expect(page.getByLabel('Password')).toBeVisible()});
