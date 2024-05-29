FROM spark:3.4.1-scala

ENV PATH="$PATH:/opt/spark/bin"

# Configure Spark and cache the database drivers
RUN mkdir /opt/spark/conf
COPY spark-defaults.conf /opt/spark/conf
RUN echo :quit | spark-shell

COPY sync.sc .
CMD ["bash", "-c", "echo :quit | spark-shell -I sync.sc"]
