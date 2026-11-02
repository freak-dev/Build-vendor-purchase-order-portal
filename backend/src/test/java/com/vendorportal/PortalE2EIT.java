package com.vendorportal;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.ExtensionContext;
import org.junit.jupiter.api.extension.RegisterExtension;
import org.junit.jupiter.api.extension.TestWatcher;
import org.openqa.selenium.*;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.WebDriverWait;
import java.net.URI;
import java.net.http.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.time.Duration;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class PortalE2EIT {
 private WebDriver driver;private WebDriverWait wait;private final String base=System.getenv().getOrDefault("E2E_BASE_URL","http://localhost:8088");private final String username=System.getenv().getOrDefault("E2E_USER","admin");private final String password=System.getenv().getOrDefault("E2E_PASSWORD",System.getenv().getOrDefault("ADMIN_PASSWORD","change-me"));private final ObjectMapper json=new ObjectMapper();
 @RegisterExtension final TestWatcher screenshots=new TestWatcher(){@Override public void testFailed(ExtensionContext c,Throwable e){if(driver instanceof TakesScreenshot cam)try{Path folder=Path.of("target","selenium-screenshots");Files.createDirectories(folder);cam.getScreenshotAs(OutputType.FILE).toPath().toFile().renameTo(folder.resolve(c.getRequiredTestMethod().getName()+".png").toFile());}catch(Exception ignored){}}};
 @BeforeEach void open(){ChromeOptions o=new ChromeOptions();o.addArguments("--headless=new","--no-sandbox","--disable-dev-shm-usage","--window-size=1440,1000");driver=new org.openqa.selenium.chrome.ChromeDriver(o);wait=new WebDriverWait(driver,Duration.ofSeconds(25));driver.get(base);driver.findElement(By.cssSelector("input[aria-label='Username']")).sendKeys(username);driver.findElement(By.cssSelector("input[aria-label='Password']")).sendKeys(password);driver.findElement(By.xpath("//button[normalize-space()='Sign in']")).click();wait.until(d->d.findElement(By.tagName("h1")).getText().equals("Good morning"));}
 @AfterEach void close(){if(driver!=null)driver.quit();}
 @Test @Order(1) void loginShowsLiveDashboard(){assertTrue(driver.getPageSource().contains("Live data"));}
 @Test @Order(2) void vendorCanBeCreated(){String name="Selenium Vendor "+UUID.randomUUID().toString().substring(0,8);driver.findElement(By.xpath("//button[normalize-space()='Vendors']")).click();driver.findElement(By.xpath("//button[contains(.,'Add vendor')]")).click();List<WebElement> f=driver.findElements(By.cssSelector(".modal input"));f.get(0).sendKeys(name);f.get(1).sendKeys("selenium-"+UUID.randomUUID()+"@example.test");driver.findElement(By.xpath("//div[contains(@class,'modal')]//button[normalize-space()='Add vendor']")).click();wait.until(d->d.getPageSource().contains(name));assertTrue(driver.getPageSource().contains(name));}
 @Test @Order(3) void productCanBeCreated(){String sku="SEL-"+UUID.randomUUID().toString().substring(0,8);driver.findElement(By.xpath("//button[normalize-space()='Products']")).click();driver.findElement(By.xpath("//button[contains(.,'Add product')]")).click();List<WebElement> f=driver.findElements(By.cssSelector(".modal input"));f.get(0).sendKeys(sku);f.get(1).sendKeys("Selenium Product");f.get(2).clear();f.get(2).sendKeys("Testing");f.get(3).sendKeys("19.50");f.get(4).sendKeys("12");f.get(5).sendKeys("2");driver.findElement(By.xpath("//div[contains(@class,'modal')]//button[normalize-space()='Add product']")).click();wait.until(d->d.getPageSource().contains(sku));assertTrue(driver.getPageSource().contains(sku));}
 @Test @Order(4) void purchaseOrderCanBeCreated(){Fixture f=fixture();driver.findElement(By.xpath("//button[normalize-space()='Purchase orders']")).click();driver.findElement(By.xpath("//button[contains(.,'New order')]")).click();List<WebElement>s=driver.findElements(By.cssSelector(".modal select"));new Select(s.get(0)).selectByVisibleText(f.vendor);new Select(s.get(1)).selectByIndex(1);driver.findElement(By.xpath("//div[contains(@class,'modal')]//button[normalize-space()='Create order']")).click();wait.until(d->d.getPageSource().contains("Purchase order created"));assertTrue(driver.getPageSource().contains("PO-"));}
 @Test @Order(5) void purchaseOrderCanBeApproved(){Fixture f=fixture();String po=createOrder(f);driver.findElement(By.xpath("//button[normalize-space()='Purchase orders']")).click();WebElement action=wait.until(d->d.findElement(By.xpath("//button[contains(@class,'small') and contains(.,'"+po+"')]") ));action.click();wait.until(d->d.getPageSource().contains("Order approved"));assertTrue(driver.getPageSource().contains("Order approved"));}
 private record Fixture(String vendor,String product,long vendorId,long productId){}
 private Fixture fixture(){String x=UUID.randomUUID().toString().substring(0,8),vendor="E2E Vendor "+x,sku="E2E-"+x;Map<String,Object>v=post("/api/vendors",Map.of("name",vendor,"email","e2e-"+x+"@example.test","phone","5550000","address","Automation"));Map<String,Object>p=post("/api/products",Map.of("sku",sku,"name","E2E Product "+x,"description","","category","Testing","unitPrice",20,"stockQuantity",5,"reorderThreshold",1));return new Fixture(vendor,"E2E Product "+x,((Number)v.get("id")).longValue(),((Number)p.get("id")).longValue());}
 private String createOrder(Fixture f){Map<String,Object>o=post("/api/orders",Map.of("vendorId",f.vendorId,"items",List.of(Map.of("productId",f.productId,"quantity",2)),"notes","Selenium test"));return String.valueOf(o.get("po_number"));}
 @SuppressWarnings("unchecked") private Map<String,Object>post(String route,Object body){try{String token=Base64.getEncoder().encodeToString((username+":"+password).getBytes(StandardCharsets.UTF_8));HttpRequest req=HttpRequest.newBuilder(URI.create(base+route)).header("Authorization","Basic "+token).header("Content-Type","application/json").POST(HttpRequest.BodyPublishers.ofString(json.writeValueAsString(body))).build();HttpResponse<String>res=HttpClient.newHttpClient().send(req,HttpResponse.BodyHandlers.ofString());if(res.statusCode()<200||res.statusCode()>=300)throw new IllegalStateException("Fixture API returned "+res.statusCode()+": "+res.body());return json.readValue(res.body(),Map.class);}catch(Exception e){throw new IllegalStateException("Could not create Selenium fixture",e);}}
}
