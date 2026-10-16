FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
COPY webpage ./webpage
COPY testng.xml .
RUN mvn test-compile -B

FROM maven:3.9.6-eclipse-temurin-17
WORKDIR /app

COPY --from=build /app /app

RUN apt-get update && apt-get install -y wget gnupg ca-certificates fonts-liberation 
    && mkdir -p /etc/apt/keyrings 
    && wget -qO- https://dl.google.com/linux/linux_signing_key.pub 
       | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg 
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" 
       > /etc/apt/sources.list.d/google-chrome.list 
    && apt-get update && apt-get install -y google-chrome-stable 
    && rm -rf /var/lib/apt/lists/*

CMD ["mvn", "test"]