FROM staphb/vadr:1.6.3-hav-flu2

RUN wget https://ftp.ncbi.nlm.nih.gov/asn1-converters/by_program/table2asn/linux64.table2asn.gz
RUN gunzip linux64.table2asn.gz
RUN mv linux64.table2asn /usr/bin/table2asn
RUN chmod 755 /usr/bin/table2asn
RUN rm /opt/vadr/vadr/v-annotate.pl
COPY v-annotate.pl /opt/vadr/vadr/v-annotate.pl
RUN chmod 755 /opt/vadr/vadr/v-annotate.pl


