### 1. Create .NET Project
dotnet new console -n KafkaProducer

### 2. Add Confluent Kafka Library in KafkaProducer.csproj
```bash
  <ItemGroup>
    <PackageReference Include="Confluent.Kafka" Version="2.3.0" />
    <PackageReference Include="Microsoft.Extensions.Configuration" Version="8.0.0" />
  </ItemGroup>
```

### 3. Write your script, you can find example script in the dotnet_files folder.

### 4. Build your project
dotnet build

### 5. Run your script
dotnet run