import express from 'express'
import { getMessagesISend,getDoctor,getDoctors, getPatient, getPatients, getMessages , setDoctor, setPatient, setMessage, updatePatient, updateDoctor, getDoctorByID, getPatientByID, doctorOnlineStatus, getMessagesIReciever} from './database.js'

const app = express()
app.use(express.json())

app.listen(8080, () => {
    console.log('server is running on port 8080')
})

app.use((err, req, res, next) => {
    console.error(err.stack)
    res.status(500).send('Something broke!')
})

app.get("/doctors",async (req, res)=>{
    const doctors = await getDoctors()
    res.send(doctors)
})

app.post("/doctor/id",async (req, res)=>{
    const{doctorID} = req.body
    const doctor = await getDoctorByID(doctorID)
    res.send(doctor)
})


app.get("/patients",async (req, res)=>{
    const patients = await getPatients()
    res.send(patients)
})

app.post("/patient/id",async (req, res)=>{
    const{patientID} = req.body
    const patient = await getPatientByID(patientID)
    res.send(patient)
})

app.post("/messages", async (req, res)=>{
    const {messageSender, messageReciever} = req.body
    const messages = await getMessages(messageSender, messageReciever)
    res.send(messages)
})

app.post("/logpat", async (req, res)=>{
    const {PatientMail, PatientPassword} = req.body
    const patient = await getPatient(PatientMail, PatientPassword)
    res.send(patient)
})

app.post("/logdoc", async (req, res)=>{
    const {doctorMail, doctorPassword} = req.body
    const doctor = await getDoctor(doctorMail, doctorPassword)
    res.send(doctor)
})

app.post("/doctor", async(req, res) =>{
    const {doctorName, doctorMail, doctorPassword, doctorPhoto, doctorGender, doctorDiscipline, doctorMastery1,
    doctorGraduate, doctorWorkplace, doctorOnline} = req.body;
    const doctor = await setDoctor(doctorName, doctorMail, doctorPassword, doctorPhoto, doctorGender, doctorDiscipline, doctorMastery1, 
    doctorGraduate, doctorWorkplace, doctorOnline);
        res.send(doctor)
})

app.post("/patient", async(req, res) =>{
    const {PatientName, PatientMail, PatientPassword, PatientPhoto, PatientGender, PatientOnline} = req.body;
    const patient = await setPatient(PatientName, PatientMail, PatientPassword, PatientPhoto, PatientGender, PatientOnline);
        res.send(patient)
})

app.post("/message", async(req, res) =>{
    const {messageSender, SenderName , messageReciever, messageText, messageMedia} = req.body;
    const message = await setMessage(messageSender,SenderName, messageReciever, messageText, messageMedia);
        res.send(message)
})

app.patch("/patient", async(req,res)=>{
    const {PatientName , PatientPassword ,PatientID} = req.body;
    const patient = await updatePatient(PatientName , PatientPassword , PatientID);
        res.send(patient)
})

app.patch("/doctor", async(req,res)=>{
    const {doctorName , doctorPassword , doctorWorkplace, doctorGraduate, doctorDiscipline, doctorMastery1,doctorID} = req.body;
    const doctor = await updateDoctor(doctorName, doctorPassword, doctorWorkplace, doctorGraduate, doctorDiscipline, doctorMastery1, doctorID);
        res.send(doctor)
})

app.patch("/doctor/online", async(req,res)=>{
    const {status, doctorMail, doctorPassword} = req.body;
    const doctor = await doctorOnlineStatus(status, doctorMail, doctorPassword);
        res.send(doctor)
})

app.post("/messages/chats", async (req, res)=>{
    const {messageSender} = req.body
    const messages = await getMessagesISend(messageSender)
    res.send(messages)
})

app.post("/messages/chat", async (req, res)=>{
    const {messageReciever} = req.body
    const messages = await getMessagesIReciever(messageReciever)
    res.send(messages)
})