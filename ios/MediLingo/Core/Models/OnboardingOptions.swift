import Foundation

// Onboarding choices. rawValue matches the DB CHECK constraints (profiles);
// `label` is the Spanish UI copy (CLAUDE.md: UI Spanish, content English).

enum HealthcareRole: String, CaseIterable, Identifiable, Sendable {
    case student, doctor, nurse, dentist, therapist, paramedic, assistant, other
    var id: String { rawValue }
    var label: String {
        switch self {
        case .student: "Estudiante"
        case .doctor: "Médico/a"
        case .nurse: "Enfermero/a"
        case .dentist: "Dentista"
        case .therapist: "Terapeuta"
        case .paramedic: "Paramédico/a"
        case .assistant: "Asistente"
        case .other: "Otro"
        }
    }
    var icon: String {
        switch self {
        case .student: "graduationcap.fill"
        case .doctor: "stethoscope"
        case .nurse: "cross.case.fill"
        case .dentist: "mouth.fill"
        case .therapist: "figure.walk"
        case .paramedic: "cross.circle.fill"
        case .assistant: "person.fill"
        case .other: "ellipsis.circle.fill"
        }
    }
}

enum EnglishLevel: String, CaseIterable, Identifiable, Sendable {
    case beginner, intermediate, advanced
    var id: String { rawValue }
    var label: String {
        switch self {
        case .beginner: "Principiante"
        case .intermediate: "Intermedio"
        case .advanced: "Avanzado"
        }
    }
    var subtitle: String {
        switch self {
        case .beginner: "Sé lo básico"
        case .intermediate: "Puedo tener conversaciones simples"
        case .advanced: "Me comunico con fluidez"
        }
    }
}

enum LearningGoal: String, CaseIterable, Identifiable, Sendable {
    case enarm, research, patientCare = "patient_care", remoteWork = "remote_work"
    case travelMedicine = "travel_medicine", usmle, general
    var id: String { rawValue }
    var label: String {
        switch self {
        case .enarm: "Preparar el ENARM"
        case .research: "Investigación y publicaciones"
        case .patientCare: "Atención a pacientes"
        case .remoteWork: "Trabajo remoto / telemedicina"
        case .travelMedicine: "Viajes y rotaciones"
        case .usmle: "Preparar el USMLE"
        case .general: "Mejorar en general"
        }
    }
}

enum DailyGoal: Int, CaseIterable, Identifiable, Sendable {
    case casual = 50, regular = 100, serious = 150, intense = 200
    var id: Int { rawValue }
    var label: String {
        switch self {
        case .casual: "Casual"
        case .regular: "Constante"
        case .serious: "Serio"
        case .intense: "Intenso"
        }
    }
    var minutes: String {
        switch self {
        case .casual: "5 min/día"
        case .regular: "10 min/día"
        case .serious: "15 min/día"
        case .intense: "20+ min/día"
        }
    }
}
