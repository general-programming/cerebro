FROM sbtscala/scala-sbt:eclipse-temurin-jammy-11.0.22_7_1.9.9_3.3.1 as builder

WORKDIR /build
COPY . .

RUN sed -i '/<appender-ref ref="FILE"\/>/d' conf/logback.xml && \
    sbt universal:packageZipTarball

FROM eclipse-temurin:11

WORKDIR /app

COPY --from=builder /build/target/universal/*.tgz .

RUN tar xfv *.tgz --strip-components=1 && \
    rm *.tgz && \
    addgroup -gid 1000 cerebro \
    && adduser -q --system --no-create-home --disabled-login -gid 1000 -uid 1000 cerebro \
    && chown -R cerebro:cerebro /app

USER cerebro

CMD [ "/app/bin/cerebro", "-v" ]