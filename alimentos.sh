# Script para procesamiento de muestras de alimentos version 1.0
# realiza un procesamiento básico:
# - alineamiento contra el genoma de referencia
# - conversion a bam, ordenado e indexado
# - conteo de cobertura
# - filtrado por tamaño para analisis downstream
# - Hernán Olivera. IGEVET-CONICET-UNLP Licence: GPL

echo Alignment
for file in ../fastq/*.fastq do 
bwa mem -T 20 -t 16 -M igevet_id_contextSeq_extendido.fasta $file >$(basename $file .fastq).sam
done

echo Sam 2 Bam
for file in fastq/*.fastq do
bwa mem genoma/alimentos_2.fa sam/$file>$file.sam
done

echo Sort & Index
for file in *.sam do
samtools sort $file >bam/$(basename $file .sam).bam
samtools index bam/$(basename $file .sam).bam
done

echo Multicov
bedtools multicov -bams sample.bam -bed ../hotspot.bed>multicov.txt


for file in *.sam
do
echo $file
samtools view -e '[NM]<5 && qlen>50' $file >minsize50/$file
samtools view -e '[NM]<5 && qlen>100' $file >minsize100/$file
done

for file in minsize50/*.sam
do
echo $file
samtools sort $file >minsize50/$(basename $file .sam).bam
samtools index minsize50/$(basename $file .sam).bam
done

for file in minsize100/*.sam
do
echo $file
samtools sort $file >minsize100/$(basename $file .sam).bam
samtools index minsize100/$(basename $file .sam).bam
done

cd minsize50 
bedtools multicov -bams sample.bam -bed ../hotspot.bed>multicov50.txt

cd minsize100
bedtools multicov -bams sample.bam -bed ../hotspot.bed>multicov100.txt


